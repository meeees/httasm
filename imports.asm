;;;;;;;;;;;;;;;;
; Imports File ;
;;;;;;;;;;;;;;;;

data import
    library msvcrt, 'msvcrt.dll', \
        ws2_32 , 'ws2_32.dll'

    import msvcrt,\
        printf , 'printf',\
        scanf , 'scanf',\
        exit, 'exit'

    import ws2_32,\
        WSAStartup , 'WSAStartup', \
        WSACleanup , 'WSACleanup', \
        socket , 'socket', \
        setsockopt , 'setsockopt', \
        bind , 'bind', \
        listen , 'listen', \
        accept , 'accept', \
        recv , 'recv', \
        send , 'send'
end data
