using System;
using System.Collections.Generic;
using System.Text;

namespace ConsoleQuotes.MT4
{
    /// <summary>
    /// Response
    /// </summary>
    public class Response
    {
        /// <summary>
        /// Login
        /// </summary>
        public int Login { get; set; }

        /// <summary>
        /// Symbol
        /// </summary>
        public string Symbol { get; set; }

        /// <summary>
        /// Ask
        /// </summary>
        public double Ask { get; set; }

        /// <summary>
        /// Bid
        /// </summary>
        public double Bid { get; set; }

        /// <summary>
        /// Spread
        /// </summary>
        public int Spread { get; set; }
    }
}
