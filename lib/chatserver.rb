#
# Серверная часть чата
#
# Для запуска сервера необходимо указать имя хоста и порт
# Сервер останавливается нажатием сочетания ctrl+C
#
class ChatServer

    #
    # Запуск и начало работы сервера
    #
    def initialize(host, port)
        # Создание сервера
        @server = TCPServer.new(host, port)
        # Список клиентов, соединяющихся с сервером:
        # {
        #    socket: сокет клиента
        #    thread: поток обработки сообщений от клиента
        #    login:  логин клиента
        # }
        @clients = []
        # TODO:
        thread_block!(false)
        # Обрабока входящих соединений с сервером
        put_message("Сервер запущен !")
        waiting
    end


private

    #
    # Блокировка/разблокировка доступа к общим ресурсам
    # другим потокам
    #
    def thread_block!(status)
        @thread_block = status
    end


    #
    # Заняты ли общие ресурсы каким-то потоком
    #
    def thread_block?
        @thread_block
    end


    #
    # Ожидание подключения клиетов
    #
    def waiting
        loop do
            begin
                # Установка соединения с клиентом
                new_client = @server.accept
                # Обработка сообщений от клиента
                listen(new_client)
            rescue Interrupt
                # Остановка сервера по нажатию ctrl+C
                close
            end
        end
    end


    #
    # Завершение работы сервера
    #
    def close
        # Отправка сообщения об остановке сервера всем клиентам
        put_all(quit())
        # Закрытие всех потоков и соединений
        put_message("Сервер завершает работу !")
        @clients.each do |client|
            client[:thread].exit
            client[:socket].close
        end
    end


    #
    # Запуск потока обработки сообщений от клиента
    #
    def listen(socket)
        # Запуск потока
        thread = Thread.new do
            # Получение логина клиента
            login = get_login(socket)
            # Добавление информации о клиенте
            append_client(thread, socket, login)
            # Цикл обработки сообщений клиента
            loop do
                # Получение сообщения от клиента
                message_from_client = get(socket)
                # Вывод сообщения клиента на сервере
                put_message(message_from_client)
                # Обрботка сообщения клиента
                message_type, message_data = parse_message(message_from_client)
                case message_type
                when "QUIT"
                    # Удаление инфорации о клиенте и закрытие соединения
                    remove_client(login)
                    return
                when "MESSAGE"
                    # Отправка сообщения клиента остальным клиентам
                    put_all(login, message("#{login}: #{message_data}"))
                end
            end
        end
    end


    #
    # Вывод сообщения на сервере
    #
    def put_message(message)
        puts message
    end


    #
    # Отправка сообщения клиенту
    #
    def put(socket, message)
        socket.print(message)
    end


    #
    # Отправка сообщения всем клиентам, кроме заданного
    #
    def put_all(login, message)
        @clients.each do |client|
            unless client[:login] == login
                client[:socket].print(message)
            end
        end
    end


    #
    # Получение сообщения от клиента
    #
    def get(socket)
        socket.read
    end


    #
    # Получение логина от клиента
    #
    def get_login(socket)
        loop do
            message = get(socket)
            _message_type, message_data = parse_message(message)
            put(socket login(message_data))
            break if message_data == "OK"
        end
    end


    #
    # Обработка сообщения клиента
    #
    def parse_message(message)
        message_type, _sep, message_data = message.partition(" ")
        return [message_type, message_data]
    end


    #
    # Добавление информации о клиенте
    #
    def append_client(thread, socket, login)
        @clients << {
            thread: thread,
            socket: socket,
            login: login
        }
    end


    #
    # Удаление информации о клиенте и
    # отключение клиента от сервера
    #
    def remove_client(login)
        @clients.each_index do |i|
            if @clients[i][:login] == login
                @client.pop(i)
                break
            end
        end
    end


    #
    # Сообщение-ответ сервера о приёме
    # и проверке логина клиента
    #
    def login(data)
        "LOGIN #{data}"
    end

end
