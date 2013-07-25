Imports System.Data.SqlClient
Imports System.IO

Imports Excel_office = Microsoft.Office.Interop.Excel
Imports ExcelAutoFormat = Microsoft.Office.Interop.Excel.XlRangeAutoFormat
Public Class excel
    Private myConn As SqlConnection
    Private sqComm As SqlCommand
    Private mySqlTran As SqlTransaction
    Private s_ConnString As String = ""

    Private Sub btExport_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btExport.Click
        If setConn() Then           ' SET DATABASE CONNECTION.
            ' GET DETAILS.
            Dim TB_NAME As String = "changes"
            Dim sql_select As String = "SELECT * FROM " & TB_NAME
            Dim sqlcommand As New SqlCommand(sql_select, myConn)

            Dim da As New SqlDataAdapter(sqlcommand)
            Dim ds As New DataSet()
            da.Fill(ds, TB_NAME)

            Dim column As New DataColumn
            Try
                If ds.Tables(0).Columns.Count > 0 Then
                    Dim xlApp As Microsoft.Office.Interop.Excel.Application
                    Dim xlWorkBook As Excel_office.Workbook
                    Dim xlWorkSheet As Microsoft.Office.Interop.Excel.Worksheet
                    Dim path As String = "C:\cygwin\home\windows\Evix_assignment\"
                    If Not Directory.Exists(path) Then                          ' CHECK IF THE FOLDER EXISTS.
                        Directory.CreateDirectory(path)
                    End If

                    ' ADD A WORKBOOK USING THE EXCEL APPLICATION.
                    xlApp = New Microsoft.Office.Interop.Excel.Application
                    xlApp.DisplayAlerts = False
                    xlWorkBook = xlApp.Workbooks.Open("C:\cygwin\home\windows\Evix_assignment\sample.xlsx")
                    xlWorkSheet = xlWorkBook.Worksheets("SampleSheet")

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

                    xlWorkSheet.SaveAs(path & "sample.xlsx")   ' SAVE THE FILE IN A FOLDER.

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

    Private Function setConn() As Boolean
        Try
            s_ConnString = "Server=localhost;Database=TestDB;Trusted_Connection=True;Connect Timeout=5;"
            myConn = New SqlConnection(s_ConnString)
            myConn.Open()
        Catch ex As Exception
            Return False
        End Try

        Return True
    End Function

End Class
