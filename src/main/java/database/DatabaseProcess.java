package database;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class DatabaseProcess {
	private static Connection conn;
	private static PreparedStatement pstmt;
	private static ResultSet rsExecuteQuery;
	private static ResultSet rsExecuteQuery2;
	private static ResultSet rsExecuteQuery3;

	private static int rsExecuteUpdate;
	private static ResultSetMetaData rsmd;
	private static DatabaseMetaData dbmd;

	public void exit() throws SQLException {
		if (rsExecuteQuery != null)
			rsExecuteQuery.close();
		if (rsExecuteQuery2 != null)
			rsExecuteQuery2.close();
		if (rsExecuteQuery3 != null)
			rsExecuteQuery3.close();
		if (pstmt != null)
			pstmt.close();
		if (conn != null)
			conn.close();
	}// end exit()

	@RequestMapping("process.do")
	public @ResponseBody Map<String, Object> dbProcess(HttpServletRequest request) {
		DatabaseConnect dbc = new DatabaseConnect();
		//받은 쿼리문
		String query = request.getParameter("query").trim();
		List<List> allList = new ArrayList<List>();
		Map<String, Object> map = new HashMap<String, Object>();
		//수행시간
		long start = System.currentTimeMillis();
		String[] words = query.split("\\s");

		if (words[0].equals("select") || words[0].equals("SELECT")) {
			try {
				String executeQuery = "ExecuteQuery";
				map.put("executeQuery", executeQuery);
				// db연결
				conn = dbc.init(request);
				// 쿼리문장 분석
				pstmt = conn.prepareStatement(query);
				// 쿼리실행
				rsExecuteQuery = pstmt.executeQuery();
				// ResultSet 메타데이터 얻기
				rsmd = rsExecuteQuery.getMetaData();
				// DatabaseMetaData 얻기
				dbmd = conn.getMetaData();

				// SELECT : 컬럼명
				int columnCount = rsmd.getColumnCount();
				List<Object> columnList = new ArrayList<Object>();
				String columnName3 = null;
				for (int i = 1; i <= columnCount; i++) {
					columnName3 = rsmd.getColumnName(i);
					columnList.add(columnName3);
				}
				allList.add(columnList);

				// SELECT : 데이터
				Object data = new Object();
				List<Object> dataList = null;
				int executeCount = 0;
				while (rsExecuteQuery.next()) {
					dataList = new ArrayList<Object>();
					executeCount++;
					for (int i = 1; i <= columnCount; i++) {
						data = rsExecuteQuery.getObject(i);
						dataList.add(data);
					}
					allList.add(dataList);
				}
				map.put("list", allList);
				map.put("executeCount", executeCount);
			} catch (SQLException e) {
				e.printStackTrace();
				map.put("e", e);
				System.out.println("e객체: " + e.getClass().getName());
			} finally {
				try {
					exit();
				} catch (SQLException e) {
					e.printStackTrace();
					map.put("e", e);
				}
			}
		} // end if

		else if (words[0].equals("insert") || words[0].equals("INSERT") || words[0].equals("delete")
				|| words[0].equals("DELETE") || words[0].equals("update") || words[0].equals("UPDATE")) {
			try {
				String executeUpdate = "executeUpdate";
				map.put("executeUpdate", executeUpdate);
				conn = dbc.init(request);
				pstmt = conn.prepareStatement(query);
				rsExecuteUpdate = pstmt.executeUpdate();
			} catch (SQLException e) {
				e.printStackTrace();
				map.put("e", e);
			} finally {
				try {
					exit();

				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		} // end else if

		// DESC 구현
		else if (words[0].equals("desc") || words[0].equals("DESC")) {
			try {
				// db연결
				conn = dbc.init(request);
				// 쿼리문장 분석
				//pstmt = conn.prepareStatement(query);
				// 쿼리실행
				//rsExecuteQuery = pstmt.executeQuery();
				// DatabaseMetaData 얻기
				dbmd = conn.getMetaData();
				String table = words[1].substring(0, words[1].length() - 0);
				String DESC = "DESC";
				map.put("DESC", DESC);

				// DESC : 컬럼정보
				rsExecuteQuery2 = dbmd.getColumns(null, null, table, null);
				List<String> getColumnsNameInfo = new ArrayList<String>();
				List<Integer> getColumnsOrdinalPositionInfo = new ArrayList<Integer>();
				List<String> getColumnsColumnDefInfo = new ArrayList<String>();
				List<String> getColumnsIsNullableInfo = new ArrayList<String>();
				List<Integer> getColumnsDataTypeInfo = new ArrayList<Integer>();
				List<Integer> getColumnsNumPrecRadixInfo = new ArrayList<Integer>();
				List<Integer> getColumnsColumnSizeInfo = new ArrayList<Integer>();
				while (rsExecuteQuery2.next()) {
					String columnName1 = rsExecuteQuery2.getString("COLUMN_NAME");
					int ordinalPosition = rsExecuteQuery2.getInt("ORDINAL_POSITION");
					String columnDef = rsExecuteQuery2.getString("COLUMN_DEF");
					String isNullable = rsExecuteQuery2.getString("IS_NULLABLE");
					int dataType = rsExecuteQuery2.getInt("DATA_TYPE");
					int numPrecRadix = rsExecuteQuery2.getInt("NUM_PREC_RADIX");
					int columnSize = rsExecuteQuery2.getInt("COLUMN_SIZE");

					getColumnsNameInfo.add(columnName1);
					getColumnsOrdinalPositionInfo.add(ordinalPosition);
					getColumnsColumnDefInfo.add(columnDef);
					getColumnsIsNullableInfo.add(isNullable);
					getColumnsDataTypeInfo.add(dataType);
					getColumnsNumPrecRadixInfo.add(numPrecRadix);
					getColumnsColumnSizeInfo.add(columnSize);
				} // end while
				map.put("getColumnsNameInfo", getColumnsNameInfo);
				map.put("getColumnsOrdinalPositionInfo", getColumnsOrdinalPositionInfo);
				map.put("getColumnsColumnDefInfo", getColumnsColumnDefInfo);
				map.put("getColumnsIsNullableInfo", getColumnsIsNullableInfo);
				map.put("getColumnsDataTypeInfo", getColumnsDataTypeInfo);
				map.put("getColumnsNumPrecRadixInfo", getColumnsNumPrecRadixInfo);
				map.put("getColumnsColumnSizeInfo", getColumnsColumnSizeInfo);

				// DESC : 인덱스 정보
				rsExecuteQuery3 = dbmd.getIndexInfo(null, null, table, false, false);
				while (rsExecuteQuery3.next()) {
					String tableCat = rsExecuteQuery3.getString("TABLE_CAT");
					String tableSchema = rsExecuteQuery3.getString("TABLE_SCHEM");
					String tableName = rsExecuteQuery3.getString("TABLE_NAME");
					Boolean nonUnique = rsExecuteQuery3.getBoolean("NON_UNIQUE");
					String indexQualifier = rsExecuteQuery3.getString("INDEX_QUALIFIER");
					String indexName = rsExecuteQuery3.getString("INDEX_NAME");
					Short type = rsExecuteQuery3.getShort("TYPE");
					Short ordinalPosition = rsExecuteQuery3.getShort("ORDINAL_POSITION");
					String columnName2 = rsExecuteQuery3.getString("COLUMN_NAME");
					String ascOrDesc = rsExecuteQuery3.getString("ASC_OR_DESC");
					int cardinality = rsExecuteQuery3.getInt("CARDINALITY");
					int pages = rsExecuteQuery3.getInt("PAGES");

					map.put("tableCat", tableCat);
					map.put("tableSchema", tableSchema);
					map.put("tableName", tableName);
					map.put("nonUnique", nonUnique);
					map.put("indexQualifier", indexQualifier);
					map.put("indexName", indexName);
					map.put("type", type);
					map.put("ordinalPosition", ordinalPosition);
					map.put("columnName2", columnName2);
					map.put("ascOrDesc", ascOrDesc);
					map.put("cardinality", cardinality);
					map.put("pages", pages);

				} // end while
			} catch (SQLException e) {
				e.printStackTrace();
				map.put("e", e);
			}finally {
				try {
					exit();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		} // end desc

		long end = System.currentTimeMillis();
		double executeTime = ((end - start) / 1000.0);
		map.put("executeTime", executeTime);
		return map;
	}// end doProcess()

	@RequestMapping("metadata.do")
	public @ResponseBody List<List> getMetaData(HttpServletRequest request) {
		DatabaseConnect dbc = new DatabaseConnect();
		String query = request.getParameter("query");
		List<List> listAll = new ArrayList<List>();
		try {
			//db연결
			conn = dbc.init(request);
			//쿼리문장 분석
			pstmt = conn.prepareStatement(query);
			//쿼리실행
			rsExecuteQuery = pstmt.executeQuery();
			//메타데이터 얻기
			rsmd = rsExecuteQuery.getMetaData();
			//칼럼 갯수
			int columnCount = rsmd.getColumnCount();

			String columnName = null;
			String columnType = null;
			int columnPrecision = 0;
			int columnNullable = 0;


			List list = null;
			for (int i = 1; i <= columnCount; i++) {
				// 리스트 초기화
				list = new ArrayList<Object>();
				columnName = rsmd.getColumnName(i);
				columnType = rsmd.getColumnTypeName(i);
				columnPrecision = rsmd.getPrecision(i);
				columnNullable = rsmd.isNullable(i);

				list.add(i);
				list.add(columnName);
				list.add(columnType);
				list.add(columnPrecision);
				list.add(columnNullable);

				listAll.add(list);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				exit();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return listAll;
	}// end metaData()

}// end class
