using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Hosting;
using System.Web.Services;

/// <summary>
/// Summary description for FileAccessService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class FileAccessService : System.Web.Services.WebService
{

    public FileAccessService()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    public enum ObjectType
    {
        File,
        Directory
    }

    private int nOperationResult = 0;

    public int OperationResult
    {
        get
        {
            return this.nOperationResult;
        }
    }

    [WebMethod]
    public void WirteFileByte(string sFullFilePath, byte[] bFileByteArray)
    {
        try
        {
            System.IO.FileStream file = System.IO.File.Create(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullFilePath)));

            file.Write(bFileByteArray, 0, bFileByteArray.Length);
            file.Close();

            this.nOperationResult = 1;
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            throw ex;
        }
    }
    [WebMethod]
    public void WirteFileStream(string sFullFilePath, Stream strmFile)
    {
        try
        {
            byte[] byArray = new byte[strmFile.Length];
            strmFile.Read(byArray, 0, Convert.ToInt32(strmFile.Length));
            this.WirteFileByte(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullFilePath), byArray);
            this.nOperationResult = 1;
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            throw ex;
        }
    }
    [WebMethod]
    public byte[] ReadFile(string sFullFilePath)
    {
        byte[] byArr;
        try
        {
            byArr = System.IO.File.ReadAllBytes(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullFilePath)));
            this.nOperationResult = 1;
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            byArr = null;
            throw ex;
        }
        return byArr;
    }
    [WebMethod]
    public void DeleteFile(string sFullFilPath)
    {
        try
        {
            if (File.Exists(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullFilPath))))
            {
                File.Delete(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullFilPath)));
                this.nOperationResult = 1;
            }
            else
            {
                this.nOperationResult = -1;
            }
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            throw ex;
        }
    }
    [WebMethod]
    public void CreateDirectory(string sFullDirPath)
    {
        try
        {
            bool exists = System.IO.Directory.Exists(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullDirPath)));
            if (!exists)
                System.IO.Directory.CreateDirectory(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullDirPath)));
            this.nOperationResult = 1;
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            throw ex;
        }
    }
    [WebMethod]
    public void DeleteDirectoryRecursively(string sFullDirPath, bool bDeleteAll)
    {
        try
        {
            if (bDeleteAll)
            {
                string[] files = Directory.GetFiles(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullDirPath)));
                string[] dirs = Directory.GetDirectories(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullDirPath)));

                foreach (string file in files)
                {
                    File.SetAttributes(file, FileAttributes.Normal);
                    File.Delete(file);
                }

                foreach (string dir in dirs)
                {
                    DeleteDirectory(dir);
                }

                Directory.Delete(sFullDirPath, false);
            }
            else
            {
                Directory.Delete(sFullDirPath, false);
            }
            this.nOperationResult = 1;
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            throw ex;
        }
    }
    [WebMethod]
    public void DeleteDirectory(string sFullDirPath)
    {
        try
        {
            Directory.Delete(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullDirPath)), false);
            this.nOperationResult = 1;
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            throw ex;
        }
    }
    [WebMethod]
    public void MoveFile(string sFullPath, string sMoveDirPath)
    {
        try
        {
            bool exists = System.IO.Directory.Exists(HostingEnvironment.MapPath(sMoveDirPath));
            if (!exists)
                System.IO.Directory.CreateDirectory(HostingEnvironment.MapPath(sMoveDirPath));

            string sFileToMove = Path.GetFileName(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullPath));
            File.Move(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullPath), Path.Combine(sMoveDirPath, sFileToMove)); // Try to move
            this.nOperationResult = 1;
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            throw ex;
        }
    }
    [WebMethod]
    public static List<string> ProcessDirectory(string path, string searchPattern = "*", SearchOption searchOption = SearchOption.AllDirectories)
    {
        if (searchOption == SearchOption.TopDirectoryOnly)
            return Directory.GetDirectories(path, searchPattern).ToList();

        var directories = new List<string>(ProcessDirectory(path, searchPattern));

        for (var i = 0; i < directories.Count; i++)
            directories.AddRange(ProcessDirectory(directories[i], searchPattern));

        return directories;
    }

    public List<string> GetPathFoldersList(string sFullPath)
    {
        List<string> result;
        try
        {
            result = ProcessDirectory(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullPath)).ToList<string>();
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            result = new List<string>();
        }
        return result;
    }
    [WebMethod]
    public List<string> GetPathFilesList(string sFullPath)
    {
        List<string> result;
        try
        {
            result = Directory.GetFiles(HostingEnvironment.MapPath(Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.FileServiceUploadFolder), sFullPath))).ToList<string>();
        }
        catch (Exception ex)
        {
            this.nOperationResult = -2;
            this.vLogError(ex);
            result = new List<string>();
        }
        return result;
    }

    private void vLogError(Exception oExpection)
    {
        //TODO:: Impliment Logger
        //ErrorLogger.vError(oExpection);
    }

}
