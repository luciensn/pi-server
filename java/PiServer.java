import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.InetSocketAddress;
import java.util.Date;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

public class PiServer {

	public static void main(String[] args) throws Exception {
		HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
		server.createContext("/backup", new BackupRequestHandler());
		server.setExecutor(null);
		server.start();

		String yellow = "\u001B[33m";
		System.out.println(yellow + "Pi server is up and running!");
	}

	static class BackupRequestHandler implements HttpHandler {
		public void handle(HttpExchange t) throws IOException {

			boolean success = false;

			String requestType = t.getRequestMethod();
			if (requestType.equals("POST")) {

				// get the JSON from the request body

				InputStreamReader isr = new InputStreamReader(t.getRequestBody(), "utf-8");
				BufferedReader br = new BufferedReader(isr);

				int b;
				StringBuilder buf = new StringBuilder(512);
				while ((b = br.read()) != -1) {
					buf.append((char) b);
				}

				br.close();
				isr.close();

				String text = buf.toString();

				// write the text to the file system

				Date date = new Date();
				String dateString = date.toString().replace(" ", "_").replace(":", "_");
				String filename = "backups/" + dateString + ".json";

				Writer writer = null;
				try {
					writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filename), "utf-8"));
					writer.write(text);
				} catch (IOException ex) {
					ex.printStackTrace();
				} finally {
					try {
						writer.close();
						success = true;

						// success!!
						String yellow = "\u001B[33m";
						System.out.println(yellow + "File '" + filename + "' saved successfully.");
						
					} catch (Exception ex) {
						ex.printStackTrace();
					}
				}
			}

			// send the response and close the exchange
			if (success) {
				t.sendResponseHeaders(200, 0);
			} else {
				t.sendResponseHeaders(500, 0);
			}
			
			OutputStream os = t.getResponseBody();
			os.close();
		}
	}
}
