<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>SQL-Client</title>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
	
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
	 
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
  
  <script type="text/javascript">
	$(document).ready(function() {
		$('#executeBtn').click(function () {
			drawTable();
		});//end executeBtn
		
		$('#query').keyup(function(event){
			if(event.keyCode == '120' || (event.ctrlKey && event.keyCode == '13')){
				drawTable();
			};//end if
		});//end keyup
	
		function drawTable(){
			//4개의 버튼
			executeTimeAndCount();
			dbTable();
			metaDataTable();
			columnsAndIndexesInfo();
			
			//exception 처리
			showError();
			
			//system 선택과 query문 입력
			readyForStart();
			$.ajax({
				url : "process.do",
				dataType : "json",
				type : "POST",
				data : data,
				success : function(data) {
					//예외처리
					if(data.e){
						colBtnAndInBtnHide();
						resultAndMetaBtnHide();
						tableAndMetadataHide();
						var stackTracke = data.e.stackTrace;
						var error = '';
			 	 			error += '<div style="color:red; font-size:20px;">' + data.e.message + '</div>';
			 	 			for(i=0; i<stackTracke.length; i++){
			 	 				error += '<div style="color:blue; font-size:12px;">' + stackTracke[i].className + ' ' + stackTracke[i].methodName + '('+ stackTracke[i].fileName+ ')' + '</div>';
			 	 			}
			 	 			$("#showError").append(error);
					}//end exception
					
					//select
					else if(data.executeQuery){
						function existingTable(){
							initialize();
							dbTable();
							resultAndMetaBtnShow();
							metadataHide();
							var source = '';
					 	 	for(var i=0; i < data.list.length; i++){
								source += '<tr>';						
									for(var j=0; j < data.list[i].length; j++){
										source += '<th>' + data.list[i][j] + '</th>';
									}
								source += '</tr>';
							}//end for()
					 	 	$("#showTable").append(source);
						}//end existingTable()
						
						//실행버튼 -> 결과버튼
						$('#resultBtn').click(function() {
							existingTable();
						});//end resultBtn
						
						//최초 실행버튼 눌렀을때
			 			existingTable();
					
						var time = '';
						time += '<div>' + '수행 시간: '+data.executeTime + ' ms' + '</div>';
						$("#executeTime").append(time);
						
						var count = '';
						count += '<div>' + '총 건수: ' +data.executeCount + '</div>';
						$("#executeCount").append(count);
					}//end select
					
					//insert, delete, update
					else if(data.executeUpdate){
						initialize();
						tableAndMetadataHide();
							var time = '';
							time += '<div>' + '수행 시간: '+data.executeTime + ' ms' + '</div>';
							$("#executeTime").append(time);
						}//end insert, delete, update
					
					//desc
					else if(data.DESC){
						tableAndMetadataHide();
						getColumns();
					}//end desc
				},//end success
				error : function(request, status, error) {
					alert("데이터 넘기기 실패");
				}//end error
			});//end ajax
		};//end drawTable()
		
		//메타데이터 
		$('#metaDataBtn').click(function() {
			dbTable();
			metaDataTable();
			showError();
			columnsAndIndexesInfo();
			tableHide();
			readyForStart();
			$.ajax({
				url : "metadata.do",
				dataType : "json",
				type : "POST",
				data : data,
				success : function(data) {
					var source = '';
					source += '<tr>';
					source += '<th>' + 'Index' + '</th>';
					source += '<th>' + 'name' + '</th>';
					source += '<th>' + 'type' + '</th>';
					source += '<th>' + 'precision' + '</th>';
					source += '<th>' + 'nullalble' + '</th>';
					source += '</tr>';
					for(var i=0; i < data.length; i++){
						source += '<tr>';
							for(var j=0; j < data[i].length; j++){
								source += '<th>' + data[i][j] + '</th>';
							}
						source += '</tr>';
					}//end for
					$("#showMetaData").append(source);
				},//end success
				error : function(request, status, error) {
					alert("데이터 넘기기 실패");
				}//end error
			});//end ajax
		});////end metaDataBtn event
		
		function readyForStart(){
			 select = $("#select").val();
			 query = $('#query').val();
			 data = {"select" : select, "query" : query };
		}//end readyForStart()
		
		function getColumns(){
			resultAndMetaBtnHide();
			colBtnAndInBtnShow();
			columnsAndIndexesInfo();
			readyForStart();
			$.ajax({
				url : "process.do",
				dataType : "json",
				type : "POST",
				data : data,
				success : function(data) {
					var source = '';	
					source += '<tr>';
					source += '<th>' + 'COLUMN_NAME' + '</th>';
					source += '<th>' + 'ORDINAL_POSITION' + '</th>';
					source += '<th>' + 'COLUMN_DEF' + '</th>';
					source += '<th>' + 'IS_NULLABLE' + '</th>';
					source += '<th>' + 'DATA_TYPE' + '</th>';
					source += '<th>' + 'NUM_PREC_RADIX' + '</th>';
					source += '<th>' + 'COLUMN_SIZE' + '</th>';
					source += '</tr>';
					
					for(var i=0; i<data.getColumnsNameInfo.length; i++){
						source += '<tr>';
						source += '<td>' + data.getColumnsNameInfo[i] + '</td>';
						source += '<td>' + data.getColumnsOrdinalPositionInfo[i] + '</td>';
						source += '<td>' + data.getColumnsColumnDefInfo[i] + '</td>';
						source += '<td>' + data.getColumnsIsNullableInfo[i] + '</td>';
						source += '<td>' + data.getColumnsDataTypeInfo[i] + '</td>';
						source += '<td>' + data.getColumnsNumPrecRadixInfo[i] + '</td>';
						source += '<td>' + data.getColumnsColumnSizeInfo[i] + '</td>';
						source += '</tr>';
					}//end for
					$("#showColumnsInfo").append(source);
				},//end success
				error : function(request, status, error) {
					alert("데이터 넘기기 실패");
				}//end error
			});//end ajax
		};//end getColumns()
		
		$('#columnsBtn').click(function() {
			getColumns();
		});//end columnsBtn event
		
		$('#indexesBtn').click(function() {
			columnsAndIndexesInfo();
			readyForStart();
			$.ajax({
				url : "process.do",
				dataType : "json",
				type : "POST",
				data : data,
				success : function(data) {
					var source = '';
					
					source += '<tr>';
					source += '<th>' + 'TABLE_CAT' + '</th>';
					source += '<th>' + 'TABLE_SCHEM' + '</th>';
					source += '<th>' + 'TABLE_NAME' + '</th>';
					source += '<th>' + 'NON_UNIQUE' + '</th>';
					source += '<th>' + 'INDEX_QUALIFIER' + '</th>';
					source += '<th>' + 'INDEX_NAME' + '</th>';
					source += '<th>' + 'TYPE' + '</th>';
					source += '<th>' + 'ORDINAL_POSITION' + '</th>';
					source += '<th>' + 'COLUMN_NAME' + '</th>';
					source += '<th>' + 'ASC_OR_DESC' + '</th>';
					source += '<th>' + 'CARDINALITY' + '</th>';
					source += '<th>' + 'PAGES' + '</th>';
					source += '</tr>';
					
					source += '<tr>';
					source += '<td>' + data.tableCat + '</td>';
					source += '<td>' + data.tableSchema + '</td>';
					source += '<td>' + data.tableName + '</td>';
					source += '<td>' + data.nonUnique + '</td>';
					source += '<td>' + data.indexQualifier + '</td>';
					source += '<td>' + data.indexName + '</td>';
					source += '<td>' + data.type + '</td>';
					source += '<td>' + data.ordinalPosition + '</td>';
					source += '<td>' + data.columnName2 + '</td>';
					source += '<td>' + data.ascOrDesc + '</td>';
					source += '<td>' + data.cardinality + '</td>';
					source += '<td>' + data.pages + '</td>';
					source += '</tr>';
					
					$("#showIndexesInfo").append(source);
				},//end success
				error : function(request, status, error) {
					alert("데이터 넘기기 실패");
				}//end error
			});//end ajax
		});//end indexesBtn event
		
		function initialize(){
			resultAndMetaBtnShow();
			colBtnAndInBtnHide();
			showError();
		};//end initialize()
		
		function columnsAndIndexesInfo(){
			$("#showColumnsInfo").empty();
			$("#showIndexesInfo").empty();
		};//end columnsAndIndexesInfo()
		
		function colBtnAndInBtnHide(){
			$('#columnsBtn').hide();
			$('#indexesBtn').hide();
		};//end colBtnAndInBtnHide()
		
		function colBtnAndInBtnShow(){
			$('#columnsBtn').show();
			$('#indexesBtn').show();
		};//end colBtnAndInBtnShow()
		
		function resultAndMetaBtnShow(){
			$('#resultBtn').show();
			$('#metaDataBtn').show();
		};//end resultAndMetaBtnShow()
		
		function resultAndMetaBtnHide(){
			$('#resultBtn').hide();
			$('#metaDataBtn').hide();
		};//end resultAndMetaBtnRemove()
		
		function metaDataTable(){
			$('#showMetaData').empty();
			$('#showMetaData').show();
		};//end metaDataTable()
		
		function showError(){
			$('#showError').empty();
			$('#showError').show();
		};//end showError()
		
		function executeTimeAndCount(){
			$('#executeTime').empty();
			$('#executeCount').empty();
		};//end executeTimeAndCount()
		
		function dbTable(){
			$('#showTable').empty();
			$('#showTable').show();
		};//end dbTable()
		
		function tableAndMetadataHide(){
			$('#showTable').hide();
			$('#showMetaData').hide();
		};//end tableAndMetadataHide()
		
		function metadataHide(){
			$('#showMetaData').hide();
		}//end metadataHide()
		
		function tableHide(){
			$('#showTable').hide
		}//end tableHide()
		
});//end documentReady();
	
</script>
<style type="text/css">
 @media screen and (min-width: 500px){
th, td{
	border: 1px solid;
	width: 20%;
}

#executeBtn{
  background-color: #3ADF00; 
  border: none;
  color: white;
  padding: 12px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  border-radius: 8px;
}
#executeBtn:hover{
  background : #04B404;
}

#resultBtn{
  background-color: #FE9A2E; 
  border: none;
  color: white;
  padding: 12px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  width : 15%;
  border-radius: 8px;
}
#resultBtn:hover{
  background-color:#DBA901;
}

#metaDataBtn{
  background-color: #FF0040; 
  border: none;
  color: white;
  padding: 12px 32px;
  text-align: center;    
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  width : 20%;
  border-radius: 8px;
}
#metaDataBtn:hover{
  background-color:#DF0101;
}

#columnsBtn{
  background-color: #FE2EF7; 
  border: none;
  color: white;
  padding: 12px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  width : 20%;
  border-radius: 8px;
}
#columnsBtn:hover{
  background-color:#DF01D7;
}

#indexesBtn{
  background-color: #8181F7; 
  border: none;
  color: white;
  padding: 12px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  width : 20%;
  border-radius: 8px;
}
#indexesBtn:hover{
  background-color:#0101DF;
}

#space{
	height: 20px;
}

#query, #showTable, #showMetaData{
	font-family: "Arial Black", sans-serif;
	font-weight: bold;
	color: black;
	text-shadow: 2px 8px 6px rgba(0,0,0,0.2), 0px -3px 20px rgba(255,255,255,0.4);
}

#executeBtn, #resultBtn, #metaDataBtn, #showColumnsInfo, #showIndexesInfo, #columnsBtn, #indexesBtn{
	font-family: "Arial Black", sans-serif;
	font-weight: bold;
	color: white;
	text-shadow: 2px 8px 6px rgba(0,0,0,0.2), 0px -3px 20px rgba(255,255,255,0.4);
}

#query{
	background-color:#FBFBEF;
}

#select{
background-color:#FBF8EF;  
}

}
</style>     
</head>
<body>
	<fieldset style="width: 1500px; height:1000px; background-color: #EFFBFB;">
	<div id="space"></div>
		<legend>SQL-Client</legend>
		<select id="select" style="height: 30px; font-style:italic; font-size:15pt;">
			<option value="mysql1">MySQL ism</option>
			<option value="mysql2">MySQL ism2</option>
			<option value="oracle1">Oracle ism</option>
		</select>
		
		<div id="space"></div>
		
		<div style="margin-left:590px;"><input type="button" id="executeBtn" value="실 행" style="font-size:20px;" /></div>
		
		<div id="space"></div>
		
		<textarea  rows="8" cols="50" id="query" placeholder="쿼리 입력" style="font-size:20px;"></textarea>
		
		<div id="space"></div>
		
		<div>
			<div style="display:inline;"><input type="button" id="resultBtn" value="Result" style="display:none; "></div> 
			<div style="display:inline;"><input type="button" id="metaDataBtn" value="MetaData" style="display:none; "></div> 
		</div>
		
		<div id="space"></div>
		
		<div>
			<div id="executeTime" style="display:inline;"></div>
			<div id="executeCount" style="display:inline;"></div>
		 </div>  
		 
		 <div id="space"></div>
		 
		<table id="showTable" style="display:none; border:1px solid; background-color: #FFFF00;"></table>
		<table id="showMetaData" style="display:none; border:1px solid; background-color:#FFFF00;"></table>

		<div id="showError"></div>
		
		<div>
			<div style="display:inline; "><input type="button" id="columnsBtn" value="Columns" style="display:none; " ></div>
			<div style="display:inline;"><input type="button" id="indexesBtn" value="Indexes" style="display:none; " ></div>
		</div>
		
		<div id="space"></div>
		
		<table id="showColumnsInfo" style="background-color: black; color: white;"></table>
		<table id="showIndexesInfo" style="background-color: black; color: white;"></table>
		
	</fieldset>
	
	<form action=''>
		<input type="radio" value="3412" />3412
		<input type="radio" value="3142" />3142
		<input type='submit'>
	</form>
	
	
	
	

  
	
	
	
	
	
	
	
	
</body>
</html>