using System;

namespace WebAppRestaurantExercise.Models
{
    public class Table
    {
        public int Id { get; set; }
        public int Size { get; set; }
        public int FreeSize { get; set; }
        public bool IsFree => FreeSize == Size;
    }
}