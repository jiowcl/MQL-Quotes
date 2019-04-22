using NetMQ;
using NetMQ.Sockets;
using System;

namespace ConsoleQuotes
{
    class Program
    {
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

                    if (quotesData.Length != 3)
                        continue;

                    int mt4Login = int.Parse(messageData[0]);
                    string vSymbol = quotesData[0];
                    double vAsk = double.Parse(quotesData[1]);
                    double vBid = double.Parse(quotesData[2]);

                    Console.WriteLine("Login: " + mt4Login + ", Symbol: " + vSymbol + ", Ask: " + vAsk + ", Bid: " + vBid);
                }
            }
        }
    }
}
