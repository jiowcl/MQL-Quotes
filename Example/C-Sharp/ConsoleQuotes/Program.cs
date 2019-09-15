using NetMQ;
using NetMQ.Sockets;
using System;
using ConsoleQuotes.MT4;

namespace ConsoleQuotes
{
    public class Program
    {
        /// <summary>
        /// Main
        /// </summary>
        public static void Main(string[] args)
        {
            using (SubscriberSocket subSocket = new SubscriberSocket())
            {
                subSocket.Options.ReceiveHighWatermark = 1000;

                subSocket.Connect("tcp://localhost:5559");
                subSocket.Subscribe("");

                while (true)
                {
                    string messageReceived = subSocket.ReceiveFrameString();
                    string[] messageData = messageReceived.Split(' ');

                    if (messageData.Length != 2)
                        continue;

                    string[] quotesData = messageData[1].Split('|');

                    if (quotesData.Length != 4)
                        continue;

                    Response response = new Response
                    {
                        Login = int.Parse(messageData[0]),
                        Symbol = quotesData[0],
                        Ask = double.Parse(quotesData[1]),
                        Bid = double.Parse(quotesData[2]),
                        Spread = int.Parse(quotesData[3])
                    };

                    Console.WriteLine("Login: " + response.Login + ", Symbol: " + response.Symbol + ", Ask: " + response.Ask + ", Bid: " + response.Bid, ", Spread: " + response.Spread);
                }
            }
        }
    }
}
