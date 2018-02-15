;;;;;;;;;;;;;;;;;;;;
; HTTP Server Data ;
;;;;;;;;;;;;;;;;;;;;

http_server_string db 'httasm/0.0.1', 0

http_basic_headers db 'HTTP/1.0 200 OK', CRET, ENDL, 'httasm/0.0.1', CRET, ENDL, 'Content-Type: text/html', CRET, ENDL, CRET, ENDL, 0

http_404_response db 'HTTP/1.0 404 NOT FOUND', CRET, ENDL, 'httasm/0.0.1', CRET, ENDL, 'Content-Type: text/html', CRET, ENDL, \
	CRET, ENDL, '<html><title>Error 404: File not found</title>', CRET, ENDL, '<body><h1>Not Found</h1><br><p>The requested file was not found', \
	CRET, ENDL, 'on the server. If you entered the URL manually please check your spelling and try again.</p></body></html>',CRET, ENDL, 0

http_400_response db 'HTTP/1.0 400 BAD REQUEST', CRET, ENDL, 'Content-Type: text/html', CRET, ENDL, \
	CRET, ENDL, '<html><title>Error 400: Bad Request</title><body><h1>Bad Request</h1>', \
	CRET, ENDL, '<p>Your browser sent a bad request.</p></body></html>', CRET, ENDL, 0

http_501_response db 'HTTP/1.0 501 Method Not Implemented', CRET, ENDL, 'httasm/0.0.1', \
	CRET, ENDL, 'Content-Type: text/html', CRET, ENDL, CRET, ENDL, '<html><title>Method Not Implemented</title>',\
	CRET, ENDL, '<body><h1>Method Not Implemented</h1><p>HTTP Request method not supported.', \
	CRET, ENDL, '</body></html>', CRET, ENDL, 0

http_bad_socket db 'Invalid socket returned from socket call, error 0x%x', ENDL, 0

http_bad_sockopt db 'Bad setsockopt call, error 0x%x', ENDL, 0

http_bad_bind db 'Bad bind call, error 0x%x', ENDL, 0

http_bad_listen db 'Bad listen call, error 0x%x', ENDL, 0

http_get_str db 'GET', 0

http_path_prefix db 'htdocs', 0

; htdocs, then url, then index.html if necessary
http_path_format db '%s%.*s%s', 0

http_empty_string db 0
http_index_string db 'index.html', 0

http_read_mode db 'rb',0
