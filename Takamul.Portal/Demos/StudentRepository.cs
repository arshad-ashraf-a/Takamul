using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApplication1.Models;
using Oracle.ManagedDataAccess.Client;
using System.Text;

namespace WebApplication1.Repository
{
    public class StudentRepository
    {
        #region GetAllStudents
        public List<Student> GetAllStudents()
        {
            List<Student> lstStudents = null;
            try
            {
                OracleParameter dbParamStudentID = new OracleParameter("PIN_STUDENT_ID", OracleDbType.Int32, 0, -99, System.Data.ParameterDirection.Input);
                OracleParameter dbCursor = new OracleParameter("CV_1", OracleDbType.RefCursor, 0, DBNull.Value, System.Data.ParameterDirection.Output);
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.AppendFormat("begin GET_ALL_TST_STUDENTS (");
                stringBuilder.AppendFormat(" :{0}, ", "PIN_STUDENT_ID");
                stringBuilder.AppendFormat(" :{0} ", "CV_1");
                stringBuilder.Append("  ); end; ");

                using (var ctx = new StudentMakerModel())
                {
                    lstStudents = ctx.Database.SqlQuery<Student>(stringBuilder.ToString(), dbParamStudentID, dbCursor).ToList<Student>();
                }
            }
            catch (Exception Ex)
            {

            }
            return lstStudents;
        }
        #endregion

        #region GetStudent
        public Student GetStudent(int nStudentID)
        {
            Student oStudent = null;
           List<Student> lstStudent = null;
            try
            {
                OracleParameter dbParamStudentID = new OracleParameter("PIN_STUDENT_ID", OracleDbType.Int32, 0, nStudentID, System.Data.ParameterDirection.Input);
                OracleParameter dbCursor = new OracleParameter("CV_1", OracleDbType.RefCursor, 0, DBNull.Value, System.Data.ParameterDirection.Output);
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.AppendFormat("begin GET_ALL_TST_STUDENTS (");
                stringBuilder.AppendFormat(" :{0}, ", "PIN_STUDENT_ID");
                stringBuilder.AppendFormat(" :{0} ", "CV_1");
                stringBuilder.Append("  ); end; ");

                using (var ctx = new StudentMakerModel())
                {
                    lstStudent = ctx.Database.SqlQuery<Student>(stringBuilder.ToString(), dbParamStudentID, dbCursor).ToList<Student>();
                }
                if (lstStudent.Count > 0)
                {
                    oStudent = lstStudent[0];
                }
            }
            catch (Exception Ex)
            {

            }
            return oStudent;
        }
        #endregion

        #region InsertStudent
        public Response InsertStudent(string sStudentName, string sEmail, string sGender, string sCreatedUser)
        {
            Response oResponse = new Response();
            try
            {
                OracleParameter dbParamStudentName = new OracleParameter("PIN_STUDENT_NAME", OracleDbType.Varchar2, 0, sStudentName, System.Data.ParameterDirection.Input);
                OracleParameter dbParamStudentEmail = new OracleParameter("PIN_EMAIL", OracleDbType.Varchar2, 0, sEmail, System.Data.ParameterDirection.Input);
                OracleParameter dbParamStudentGender = new OracleParameter("PIN_GENDER", OracleDbType.Varchar2, 0, sGender, System.Data.ParameterDirection.Input);
                OracleParameter dbParamStudentCreatedUser = new OracleParameter("PIN_CREATED_USER", OracleDbType.Varchar2, 0, sCreatedUser, System.Data.ParameterDirection.Input);
                OracleParameter dbResult = new OracleParameter("POUT_RESULT", OracleDbType.Int32, System.Data.ParameterDirection.Output);
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.AppendFormat("begin INSERT_TST_STUDENT (");
                stringBuilder.AppendFormat(" :{0},", "PIN_STUDENT_NAME");
                stringBuilder.AppendFormat(" :{0},", "PIN_EMAIL");
                stringBuilder.AppendFormat(" :{0},", "PIN_GENDER");
                stringBuilder.AppendFormat(" :{0},", "PIN_CREATED_USER");
                stringBuilder.AppendFormat(" :{0}", "POUT_RESULT");
                stringBuilder.Append("  ); end; ");

                using (var ctx = new StudentMakerModel())
                {
                    ctx.Database.ExecuteSqlCommand(stringBuilder.ToString(), dbParamStudentName,
                        dbParamStudentEmail, dbParamStudentGender, dbParamStudentCreatedUser, dbResult);

                    if (Convert.ToInt32(dbResult.Value.ToString()).Equals(1))
                    {
                        oResponse.OperationResult = OperationResult.Success;
                    }
                    else
                    {
                        oResponse.OperationResult = OperationResult.Failed;
                    }
                }
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = OperationResult.Failed;
            }
            return oResponse;
        }
        #endregion

        #region UpdateStudent
        public Response UpdateStudent(int nStudentID, string sStudentName, string sEmail, string sGender, string sCreatedUser)
        {
            Response oResponse = new Response();
            try
            {
                OracleParameter dbParamStudentID = new OracleParameter("PIN_STUDENT_ID", OracleDbType.Int32, 0, nStudentID, System.Data.ParameterDirection.Input);
                OracleParameter dbParamStudentName = new OracleParameter("PIN_STUDENT_NAME", OracleDbType.Varchar2, 0, sStudentName, System.Data.ParameterDirection.Input);
                OracleParameter dbParamStudentEmail = new OracleParameter("PIN_EMAIL", OracleDbType.Varchar2, 0, sEmail, System.Data.ParameterDirection.Input);
                OracleParameter dbParamStudentGender = new OracleParameter("PIN_GENDER", OracleDbType.Varchar2, 0, sGender, System.Data.ParameterDirection.Input);
                OracleParameter dbParamStudentCreatedUser = new OracleParameter("PIN_CREATED_USER", OracleDbType.Varchar2, 0, sCreatedUser, System.Data.ParameterDirection.Input);
                OracleParameter dbResult = new OracleParameter("POUT_RESULT", OracleDbType.Int32, System.Data.ParameterDirection.Output);
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.AppendFormat("begin UPDATE_TST_STUDENT (");
                stringBuilder.AppendFormat(" :{0},", "PIN_STUDENT_ID");
                stringBuilder.AppendFormat(" :{0},", "PIN_STUDENT_NAME");
                stringBuilder.AppendFormat(" :{0},", "PIN_EMAIL");
                stringBuilder.AppendFormat(" :{0},", "PIN_GENDER");
                stringBuilder.AppendFormat(" :{0},", "PIN_CREATED_USER");
                stringBuilder.AppendFormat(" :{0}", "POUT_RESULT");
                stringBuilder.Append("  ); end; ");

                using (var ctx = new StudentMakerModel())
                {
                    ctx.Database.ExecuteSqlCommand(stringBuilder.ToString(), dbParamStudentID, dbParamStudentName,
                        dbParamStudentEmail, dbParamStudentGender, dbParamStudentCreatedUser, dbResult);

                    if (Convert.ToInt32(dbResult.Value.ToString()).Equals(1))
                    {
                        oResponse.OperationResult = OperationResult.Success;
                    }
                    else
                    {
                        oResponse.OperationResult = OperationResult.Failed;
                    }
                }
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = OperationResult.Failed;
            }
            return oResponse;
        }
        #endregion

        #region DeleteStudent
        public Response DeleteStudent(int nStudentID, string sStudentName, string sEmail, string sGender, string sCreatedUser)
        {
            Response oResponse = new Response();
            try
            {
                OracleParameter dbParamStudentID = new OracleParameter("PIN_STUDENT_ID", OracleDbType.Int32, 0, nStudentID, System.Data.ParameterDirection.Input);
                OracleParameter dbResult = new OracleParameter("POUT_RESULT", OracleDbType.Int32, System.Data.ParameterDirection.Output);
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.AppendFormat("begin DELETE_TST_STUDENT (");
                stringBuilder.AppendFormat(" :{0},", "PIN_STUDENT_ID");
                stringBuilder.AppendFormat(" :{0}", "POUT_RESULT");
                stringBuilder.Append("  ); end; ");

                using (var ctx = new StudentMakerModel())
                {
                    ctx.Database.ExecuteSqlCommand(stringBuilder.ToString(), dbParamStudentID, dbResult);

                    if (Convert.ToInt32(dbResult.Value.ToString()).Equals(1))
                    {
                        oResponse.OperationResult = OperationResult.Success;
                    }
                    else
                    {
                        oResponse.OperationResult = OperationResult.Failed;
                    }
                }
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = OperationResult.Failed;
            }
            return oResponse;
        }
        #endregion
    }
}