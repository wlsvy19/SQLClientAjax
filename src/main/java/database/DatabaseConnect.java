package database;

import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;

@Controller
public class DatabaseConnect {

	public Connection init(HttpServletRequest request) throws SQLException {
		Connection conn = null;
		Properties properties = new Properties();
		String resource = "C:\\Users\\SoluLink\\eclipse-workspace\\SQLClientAjax\\src\\main\\webapp\\resources\\dbconf.properties";
		String url = null;
		String userid = null;
		String password = null;
		String driver = null;


		try {
			//파일에 있는 경로를 읽는다.
			Reader reader = new FileReader(resource);
			//속성을 로드 한다.
			properties.load(reader);
			String system = request.getParameter("select");
			System.out.println("선택한 DB : " + system);
			// Key에 해당하는 Value값 얻어오기
			url = properties.getProperty("rdbms." + system + ".url");
			userid = properties.getProperty("rdbms." + system + ".userid");
			password = properties.getProperty("rdbms." + system + ".password");
			driver = properties.getProperty("rdbms." + system + ".driver");
			try {
				Class.forName(driver);
			} catch (ClassNotFoundException e) {
				System.out.println("DB 드라이버를 찾을 수 없습니다.");
			}
			try {
				conn = DriverManager.getConnection(url, userid, password);
				System.out.println("DB 접속 성공");
			} catch (SQLException e) {
				System.out.println("DB 접속 실패");
			}
		} catch (IOException e) {
			e.printStackTrace();
			System.out.println("DB설정 파일을 찾을 수 없습니다.");
		} finally {
			conn.close();
		}
		return DriverManager.getConnection(url, userid, password);
	}

}
