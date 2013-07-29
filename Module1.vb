Imports System.Data.SqlClient
Imports System.IO

Imports Excel_office = Microsoft.Office.Interop.Excel
Imports ExcelAutoFormat = Microsoft.Office.Interop.Excel.XlRangeAutoFormat
Module Module1

    Public Sub Main()
        Dim DB_NAME As String = "TestDB"
        Dim TB_NAME As String = "changes"
        Dim SERVER As String = "localhost"
        Dim s_ConnString As String = Nothing
        Dim PATH As String = "C:\cygwin\home\windows\Evix_assignment\"
        Dim WORKBOOK As String = "sample.xlsx"
        Dim WORKSHEET As String = "SampleSheet"
        Dim sArgs() As String = System.Environment.GetCommandLineArgs
        Dim count As Integer = 0
        For count = 1 To UBound(sArgs)
            Select Case sArgs(count).ToLower
                Case "-t"
                    TB_NAME = sArgs(count + 1)
                Case "-d"
                    DB_NAME = sArgs(count + 1)
                Case "-c"
                    s_ConnString = sArgs(count + 1)
                Case "-s"
                    SERVER = sArgs(count + 1)
                Case "-p"
                    PATH = sArgs(count + 1)
            End Select
            count = count + 2
        Next
        Dim myConn As SqlConnection
        If s_ConnString = Nothing Then
            s_ConnString = "Server=" & SERVER & ";Database=" & DB_NAME & ";Trusted_Connection=True;Connect Timeout=5;"
        End If
        myConn = New SqlConnection(s_ConnString)
        myConn.Open()
        If ConnectionState.Open Then
            ' GET DETAILS.
            Dim sql_select As String = "SELECT * FROM " & TB_NAME
            Dim sqlcommand As New SqlCommand(sql_select, myConn)
            Dim da As New SqlDataAdapter(sqlcommand)
            Dim restrictions(3) As String
            restrictions(2) = TB_NAME
            Dim ds As New DataSet()
            Dim table As DataTable = myConn.GetSchema("Tables", restrictions)

            If table.Rows.Count = 0 Then
                For i As Integer = 1 To 3
                    Console.WriteLine("Table does not exist, Exiting... " & i)
                    If i <> 3 Then
                        Threading.Thread.Sleep(1000)
                        Console.Clear()
                    End If
                Next i
                myConn.Close()
                Environment.Exit(0)

            End If

            da.Fill(ds, TB_NAME)

            Dim column As New DataColumn
            Try
                If ds.Tables(0).Columns.Count > 0 Then
                    Dim xlApp As Microsoft.Office.Interop.Excel.Application
                    Dim xlWorkBook As Excel_office.Workbook
                    Dim xlWorkSheet As Microsoft.Office.Interop.Excel.Worksheet

                    If Not Directory.Exists(PATH) Then                          ' CHECK IF THE FOLDER EXISTS.
                        Directory.CreateDirectory(PATH)
                    End If

                    ' ADD A WORKBOOK USING THE EXCEL APPLICATION.
                    xlApp = New Microsoft.Office.Interop.Excel.Application
                    xlApp.DisplayAlerts = False
                    xlWorkBook = xlApp.Workbooks.Open(PATH & WORKBOOK)
                    xlWorkSheet = xlWorkBook.Worksheets(WORKSHEET)

                    Dim iRowCnt As Integer
                    ' ROW ID FROM WHERE THE DATA STARTS SHOWING.

                    With xlWorkSheet
                        ' REMOVE HEADERS
                        For i As Integer = 1 To 15
                            .Cells(4, i).value = Nothing
                        Next
                        ' SHOW column ON THE TOP.

                        Dim iColCnt As Integer = 1
                        For Each column In ds.Tables(0).Columns
                            .Cells(4, iColCnt).value = column.ColumnName
                            iColCnt = iColCnt + 1
                        Next
                        Dim row As DataRow
                        iRowCnt = 5
                        For Each row In ds.Tables(0).Rows
                            For col As Integer = 1 To ds.Tables(0).Columns.Count
                                .Cells(iRowCnt, col).value = row(col - 1)
                            Next
                            iRowCnt = iRowCnt + 1
                        Next

                    End With

                    xlWorkSheet.SaveAs(PATH & WORKBOOK)   ' SAVE THE FILE IN A FOLDER.

                    ' CLEAR.
                    xlApp.Workbooks.Close() : xlApp.Quit()
                    xlApp = Nothing : xlWorkSheet = Nothing

                End If
            Catch ex As Exception

            Finally
                myConn.Close()
            End Try
        End If

    End Sub

End Module
