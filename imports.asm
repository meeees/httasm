;;;;;;;;;;;;;;;;
; Imports File ;
;;;;;;;;;;;;;;;;

data import
    library msvcrt, 'msvcrt.dll', \
        ws2_32 , 'ws2_32.dll', \
        kernel32 , 'kernel32.dll'

    import msvcrt,\
        printf , 'printf',\
        scanf , 'scanf',\
        exit, 'exit',\
        strcmp , 'strcmp',\
        sprintf , 'sprintf',\
        snprintf , '_snprintf',\
        strlen , 'strlen',\
        fopen , 'fopen',\
        fgets , 'fgets',\
        feof , 'feof',\
        fclose , 'fclose',\
        stricmp , '_stricmp',\
        memcpy , 'memcpy',\
        strchr , 'strchr',\
        malloc , 'malloc',\
        free , 'free'

    import ws2_32,\
        WSAStartup , 'WSAStartup', \
        WSACleanup , 'WSACleanup', \
        socket , 'socket', \
        setsockopt , 'setsockopt', \
        htons , 'htons', \
        bind , 'bind', \
        listen , 'listen', \
        accept , 'accept', \
        recv , 'recv', \
        send , 'send', \
        closesocket , 'closesocket'

    import kernel32,\
        CreateThread , 'CreateThread', \
        GetLastError , 'GetLastError'
end data
