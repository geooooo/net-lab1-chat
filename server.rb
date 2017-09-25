#
# Чат - сервер
#
# Использование класса:
#   * server = ChatServer.new(имя_хоста, порт) - создание сервера
#   * server.listen - для запуска прослушивания и передачи сообщений между
#     подключающимися клиентами
#   * Чтобы закрыть сервер, нужно нажать ctrl+C
#



require "socket"



class ChatServer


    # Запуск и инициализация сервера
    def initialize(host, port)
        # Запуск сервера
        @socket_server = TCPServer.new(host, port)
        puts "Server running..."
        # Информация о клиентах
        # {
        #   "socket" => сокет клиента,
        #   "login"  => логин клиента,
        #   "thread" => поток обработки клиента
        # }
        @clients = []
    end


    # Ожидание подключения клиентов и прислушивание каждого клиента
    def listen
        loop do
            begin
                # Ожидание подключения клиента
                client_socket = @socket_server.accept
                # Вывод сообщения об успешном подключении нового клиента
                client_login = client_socket.gets.strip
                puts "+ #{client_login} connected !"
                puts_all("+ Connected #{client_login} !", client_socket)
                # Начало прослушивания клиента
                listen_client(client_socket, client_login)
            rescue Interrupt
                # Остановка сервера и завершение работы
                puts "Server stoping..."
                @clients.each do |client|
                    client["socket"].puts "WARNING: Server stoping !"
                    client["thread"].exit
                    client["socket"].close
                end
                return
            end
        end
    end


private


    # Обработка сообщений конкретного клиента
    def listen_client(client_socket, client_login)
        # Запуск потока обработки сообщений от клиента
        client_thread = Thread.new do
            # Добавление информации о новом клиенте
            client_append(client_socket, client_login, client_thread)
            # Отправка приветствия клиенту
            client_socket.puts "Hello !"
            loop do
                # Получение сообщения от клиента
                client_message = client_socket.gets.strip
                puts "Message #{client_message.inspect} from #{client_login}"
                # Если клиент отключился
                if client_message == ":!quit"
                    puts_all("- #{client_login} exit !", client_socket)
                    puts "- #{client_login} disconnecting !"
                    # Удаление клиента
                    client_remove(client_socket, client_login, client_thread)
                    return
                end
                # Отправка сообщения клиента другим клиентам
                if client_message.empty?
                    client_socket.puts ""
                else
                    puts_all("#{client_login}: #{client_message}", client_socket)
                    client_socket.puts ""
                end
            end
        end
    end


    # Отправка сообщения всем клиентам
    def puts_all(message, not_socket)
        @clients.each do |client|
            if client["socket"] != not_socket
                client["socket"].puts message
            end
        end
    end


    # Добавление информации о клиенте
    def client_append(client_socket, client_login, client_thread)
        @clients << {
            "socket" => client_socket,
            "login"  => client_login,
            "thread" => client_thread
        }
        puts @clients.length
    end


    # Удаление информации о клиенте
    def client_remove(client_socket, client_login, client_thread)
        # i = 0
        # while i < @clients.length
        #     if @clients[i]["socket"] == client_socket and
        #        @clients[i]["socket"] == client_socket and
        #        @clients[i]["socket"] == client_socket
        #     then
        #         remove_index = i
        #     end
        #     i += 1
        # end
        # puts remove_index.inspect
        remove_index = @clients.index({
            "socket" => client_socket,
            "login"  => client_login,
            "thread" => client_thread
        })
        puts remove_index
        @client[remove_index]["thread"].exit
        @client[remove_index]["socket"].close
        @clients[remove_index..-1] = @clients[remove_index+1..-1]
    end


end



chat_server = ChatServer.new("localhost", 8080)
chat_server.listen
