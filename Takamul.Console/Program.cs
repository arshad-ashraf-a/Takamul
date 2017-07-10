using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Console
{
    public class TakamulTicketChat
    {
        public int ApplicationID { get; set; }
        public int TicketID { get; set; }
        public int TicketChatID { get; set; }
        public string ReplyMessage { get; set; }
        public string ReplyDate { get; set; }
        public string Base64ReplyImage { get; set; }
        public string RemoteFilePath { get; set; }
        public int UserID { get; set; }
        public int TicketChatTypeID { get; set; }
        public string TicketChatTypeName { get; set; }
        public string UserFullName { get; set; }
        public byte[] ByteReplyImage { get; set; }
    }
    class Program
    {
        static HttpClient client = new HttpClient();

        static void Main(string[] args)
        {

            RunAsync().Wait();
        }

        static async Task<string> GetProductAsync(string path)
        {
            HttpResponseMessage response = await client.GetAsync(path);
            var customerJsonString = await response.Content.ReadAsStringAsync();
            return customerJsonString;
        }

        static async Task RunAsync()
        {
            client.BaseAddress = new Uri("http://api.nanocomplexity.com");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            try
            {

                for (int i = 0; i < 100000; i++)
                {
                    // Get the product
                    string response = await GetProductAsync("http://api.nanocomplexity.com/api/TicketService/GetTicketChats?nTicketID=98");
                    System.Console.WriteLine(string.Format("***********************{0}*****************************", i++));
                    System.Console.WriteLine(response);
                    System.Console.WriteLine(string.Format("***********************{0}*****************************", i++));

                }

            }
            catch (Exception e)
            {
                System.Console.WriteLine(e.Message);
            }
            System.Console.ReadLine();
        }
    }






}
