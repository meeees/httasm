;;;;;;;;;;;;;;;;;;;;
; HTTP Server Data ;
;;;;;;;;;;;;;;;;;;;;

http_server_string db 'httasm/0.0.1', CRET, ENDL, 0

http_basic_headers db 'HTTP/1.1 200 OK', CRET, ENDL, 'httasm/0.0.1', CRET, ENDL, 'Content-Type: text/html', CRET, ENDL, CRET, ENDL, 0

http_404_response db 'HTTP/1.1 404 NOT FOUND', CRET, ENDL, 'httasm/0.0.1', CRET, ENDL, 'Content-Type: text/html', CRET, ENDL, \
	CRET, ENDL, '<html><title>Error 404: File not found</title>', CRET, ENDL, '<body><h1>Not Found</h1><br><p>The requested file was not found', \
	CRET, ENDL, 'on the server. If you entered the URL manually please check your spelling and try again.</p></body></html>',CRET, ENDL, 0

http_400_response db '', 0
