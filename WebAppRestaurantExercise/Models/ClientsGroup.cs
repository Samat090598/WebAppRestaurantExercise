using System;

namespace WebAppRestaurantExercise.Models
{
    public enum Status
    {
        InQueue,
        OnTable
    }
    public class ClientsGroup
    {
        public string Id { get; set; }
        public int? TableId { get; set; }
        public int Size { get; set; }
        public Status Status { get; set; }
    }
}