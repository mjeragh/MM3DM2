import os
import http.server

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        # Replace this with the directory you want to serve
        target_directory = '/path/to/your/directory'
        target_directory = os.path.realpath(target_directory)
        
        # Make sure the request is for a file within target_directory
        requested_path = os.path.realpath(super().translate_path(path))
        if not requested_path.startswith(target_directory):
            # If not, replace the path with the target directory path
            path = '/'
        return super().translate_path(path)

if __name__ == '__main__':
    http.server.test(HandlerClass=CustomHTTPRequestHandler)

