using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Text;
using WebApplication1.Repository;
using WebApplication1.Models;

namespace WebApplication1.Controllers
{
    public class StudentsController : Controller
    {
        // GET: Students
        public ActionResult Index()
        {
            StudentRepository oStudentRepository = new StudentRepository();
            var studentList = oStudentRepository.GetAllStudents();
            return View(studentList);
        }

        public ActionResult AddStudent()
        {
            return View(new Student());
        }

        public ActionResult EditStudent(int nStudentID)
        {
            StudentRepository oStudentRepository = new StudentRepository();
            var student = oStudentRepository.GetStudent(nStudentID);

            return View(student);
        }

        [HttpPost]
        public JsonResult JSaveStudent(Student oStudent)
        {
            StudentRepository oStudentRepository = new StudentRepository();
            Response oResponse = oStudentRepository.InsertStudent(oStudent.STUDENT_NAME, oStudent.EMAIL, oStudent.GENDER, "12345");
            if (oResponse.OperationResult == OperationResult.Success)
            {
                oResponse.OperationResultMessage = "Student has been created successfully.";
            }
            else
            {
                oResponse.OperationResultMessage = "Student save failed.";
            }
            return Json(new
            {
                nResult = oResponse.OperationResult,
                sResultMessage = oResponse.OperationResultMessage
            }, JsonRequestBehavior.AllowGet);
        }
    }
}