#
# Чат - клиент
#



require "socket"



class ChatClient


    # Запуск и инициализация клиента
    def initialize(host, port, login)
        @socket = TCPSocket.new(host, port)
        # Отправка серверу логина клиента
        @socket.puts login.strip
    end


    # Запуск цикла обрабоки сообщений
    def start
        loop do
            begin
                # Получение сообщения от сервера
                server_message = @socket.gets.strip
                unless server_message.empty?
                    puts server_message
                end
                if server_message == "WARNING: Server stoping !"
                    # Завершение работы клиента
                    close false
                    return
                end
                # Ввод сообщения клиента
                print "> "
                client_message = gets.strip
                if client_message == ":!quit"
                    # Завершение работы клиента
                    close
                    return
                end
                # Отправка сообщения клиента
                begin
                    @socket.puts client_message
                rescue
                    # Завершение работы клиента
                    close false
                    return
                end
            rescue Interrupt
                # Завершение работы клиента
                close false
                return
            end
        end
    end


private


    # Отключение клиента
    def close(is_soft = true)
        # Отсылка специального сообщения серверу об отключении клиента
        puts "Closing..."
        @socket.puts ":!quit" if is_soft
        @socket.close
    end


end



chat_client = ChatClient.new("localhost", 8080, "guest")
chat_client.start
