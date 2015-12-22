curl -H "Content-Type: application/json" -X GET http://localhost:8002/events
curl -H "Content-Type: application/json" -X GET http://localhost:8002/events/1
curl -H "Content-Type: application/json" -X POST -d '{"event":{"name": "test1"}}' http://localhost:8002/events
curl -H "Content-Type: application/json" -X PUT -d '{"event":{"name": "test2"}}' http://localhost:8002/events/1
curl -H "Content-Type: application/json" -X DELETE http://localhost:8002/events/1
