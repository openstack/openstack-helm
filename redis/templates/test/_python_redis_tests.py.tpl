import os
import redis


class RedisTest(object):

    def __init__(self):
        host = os.environ.get('REDIS_HOST', 'redis')
        port = os.environ.get('REDIS_PORT', 6379)
        db = os.environ.get('REDIS_DB', 0)
        self.redis_conn = redis.Redis(host, port, db)

    def test_connection(self):
        ping = self.redis_conn.ping()
        assert ping, "No connection to database"
        print("Successfully connected to database")

    def database_info(self):
        ip_port = []
        for client in self.redis_conn.client_list():
            ip_port.append(client["addr"])
        print(ip_port)
        assert self.redis_conn.client_list(), "Database client's list is null"
        return ip_port

    def test_insert_delete_data(self):
        key = "test"
        value = "it's working"
        result_set = self.redis_conn.set(key, value)
        assert result_set, "Error: SET command failed"
        print("Successfully SET keyvalue pair")
        result_get = self.redis_conn.get(key)
        assert result_get, "Error: GET command failed"
        print("Successfully GET keyvalue pair")
        db_size = self.redis_conn.dbsize()
        assert db_size > 0, "Database size not valid"
        result_delete = self.redis_conn.delete(key)
        assert result_delete == 1, "Error: Delete command failed"
        print("Successfully DELETED keyvalue pair")

    def test_client_kill(self, client_ip_port_list):
        for client_ip_port in client_ip_port_list:
            result = self.redis_conn.client_kill(client_ip_port)
            print(result)
            assert result, "Client failed to be removed"
            print("Successfully DELETED client")


client_ip_port = []
redis_client = RedisTest()
redis_client.test_connection()
client_ip_port = redis_client.database_info()
redis_client.test_insert_delete_data()
redis_client.test_client_kill(client_ip_port)
