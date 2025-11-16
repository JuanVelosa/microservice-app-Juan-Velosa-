'use strict';
const {Annotation, 
    jsonEncoder: {JSON_V2}} = require('zipkin');

const OPERATION_CREATE = 'CREATE',
      OPERATION_DELETE = 'DELETE';

class TodoController {
    constructor({tracer, redisClient, logChannel}) {
        this._tracer = tracer;
        this._redisClient = redisClient;
        this._logChannel = logChannel;
    }

    // TODO: these methods are not concurrent-safe
    async list (req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            console.log(`📋 Listing TODOs for ${req.user.username}:`, data.items);
            res.json(data.items);
        } catch (error) {
            console.error('Error listing todos:', error);
            res.status(500).json({ error: 'Failed to load todos' });
        }
    }

    async create (req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            
            // Increment ID first, then assign
            data.lastInsertedID++;
            
            const todo = {
                content: req.body.content,
                id: data.lastInsertedID
            };
            
            data.items[data.lastInsertedID] = todo;
            await this._setTodoData(req.user.username, data);

            this._logOperation(OPERATION_CREATE, req.user.username, todo.id);

            console.log(`✅ Created todo for user ${req.user.username}:`, todo);
            res.json(todo);
        } catch (error) {
            console.error('Error creating todo:', error);
            res.status(500).json({ error: 'Failed to create todo' });
        }
    }

    async delete (req, res) {
        try {
            const data = await this._getTodoData(req.user.username);
            const id = req.params.taskId;
            
            delete data.items[id];
            await this._setTodoData(req.user.username, data);

            this._logOperation(OPERATION_DELETE, req.user.username, id);

            console.log(`🗑️ Deleted todo ${id} for user ${req.user.username}`);
            res.status(204).send();
        } catch (error) {
            console.error('Error deleting todo:', error);
            res.status(500).json({ error: 'Failed to delete todo' });
        }
    }

    _logOperation (opName, username, todoId) {
        this._tracer.scoped(() => {
            const traceId = this._tracer.id;
            this._redisClient.publish(this._logChannel, JSON.stringify({
                zipkinSpan: traceId,
                opName: opName,
                username: username,
                todoId: todoId,
            }))
        })
    }

    _getTodoData (userID) {
        const key = `todos:${userID}`;
        
        // ALWAYS try Redis first - NO MEMORY CACHE
        return new Promise((resolve, reject) => {
            if (this._redisClient && this._redisClient.get) {
                this._redisClient.get(key, (err, result) => {
                    if (err) {
                        console.log('Redis error:', err);
                        // Fallback to empty data
                        const emptyData = { items: {}, lastInsertedID: 0 };
                        resolve(emptyData);
                        return;
                    }
                    
                    if (result) {
                        try {
                            const data = JSON.parse(result);
                            console.log(`✅ Loaded from Redis for user ${userID}:`, data);
                            resolve(data);
                            return;
                        } catch (parseErr) {
                            console.log('Redis parse error:', parseErr);
                        }
                    }
                    
                    // No data found, return empty
                    const emptyData = { items: {}, lastInsertedID: 0 };
                    console.log(`📭 No data in Redis for user ${userID}, returning empty`);
                    resolve(emptyData);
                });
            } else {
                console.log('Redis client not available');
                const emptyData = { items: {}, lastInsertedID: 0 };
                resolve(emptyData);
            }
        });
    }

    _setTodoData (userID, data) {
        const key = `todos:${userID}`;
        
        // FORCE save to Redis synchronously - NO MEMORY CACHE
        return new Promise((resolve, reject) => {
            if (this._redisClient && this._redisClient.set) {
                this._redisClient.set(key, JSON.stringify(data), (err) => {
                    if (err) {
                        console.error('❌ Redis save error:', err);
                        reject(err);
                    } else {
                        console.log(`💾 Data SAVED to Redis for user ${userID}:`, data);
                        resolve();
                    }
                });
            } else {
                console.error('❌ Redis client not available');
                reject(new Error('Redis not available'));
            }
        });
    }
}

module.exports = TodoController