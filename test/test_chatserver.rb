require "minitest/autorun"
require "socket"
require_relative "../lib/chatserver"

class TestChatServer < Minitest::Test

    HOST = "127.0.0.1"
    PORT = 8080


    def setup
        @thread = Thread.new do
            ChatServer.new(HOST, PORT)
        end
        sleep 0.5 # дать серверу время запуститься
    end


    def test_waiting
            begin
                socket1 = TCPSocket.new(HOST, PORT)
                socket1.close
            rescue
                assert false, "Попытка 1: Не удалось соединиться с сервером !"
            end
            begin
                socket2 = TCPSocket.new(HOST, PORT)
                socket2.close
            rescue
                assert false, "Попытка 2: Не удалось соединиться с сервером !"
            end
            begin
                socket3 = TCPSocket.new(HOST, PORT)
                socket3.close
            rescue
                assert false, "Попытка 3: Не удалось соединиться с сервером !"
            end
            assert_raises(Interrupt) do
                Process.kill("SIGINT", Process.pid)
                puts "Сервер должен прекратить работу !"
            end
    end


    def teardown
        @thread.exit
    end

end
