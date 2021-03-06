using System;
using System.Collections.Generic;
using System.Linq;
using Insight.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using WebAppRestaurantExercise.Models;
using WebAppRestaurantExercise.ViewModels;

namespace WebAppRestaurantExercise.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GroupsController : ControllerBase
    {
        private readonly SqlConnection _connection;
        Random _random = new Random();

        public GroupsController(SqlConnection connection)
        {
            _connection = connection;
        }

        [HttpPost]
        public void OnArray([FromBody] AddClientsGroup request)
        {
            if (request.Size != 0)
            {
                if (_random.Next(1, 11) <= 3)
                {
                    // Получаем первую попавшую группу из базы
                    var groupOnTable = _connection.Query<ClientsGroup>("GetClientsGroupOnTable").FirstOrDefault();
                    OnLeave(groupOnTable);
                }
                CustomerService(request);
            }
        }

        public void CustomerService(AddClientsGroup request)
        {
            // Получаем из базы все столики которые больше или равно размеру группы
            var freeTables = _connection.Query<Table>("GetFreeTables", new {request.Size});
            ClientsGroup clientsGroup = new ClientsGroup();
            // Если нет подходящих столиков
            if (freeTables.Count == 0)
            {
                clientsGroup = new ClientsGroup
                {
                    TableId = null,
                    Size = request.Size,
                    Status = Status.InQueue
                };
                // Процедура для добавления группы клиентов в базу
                _connection.Execute("AddClientsGroup", clientsGroup);
            }
            else
            {
                Table freeTable = new Table();
                // Получаем свободный столик, если нет, то столик в котором сидят люди
                freeTable = freeTables.FirstOrDefault(f => f.IsFree) 
                                    ?? freeTables.FirstOrDefault(f => !f.IsFree);
                clientsGroup = new ClientsGroup
                {
                    TableId = freeTable.Id,
                    Size = request.Size,
                    Status = Status.OnTable
                };
                freeTable.FreeSize -= clientsGroup.Size;
                // Добавляем группу в базу данных и изменяем столик
                _connection.Execute("AddClientsGroupAndUpdateTable", new
                {
                    clientsGroup.Size, clientsGroup.Status, clientsGroup.TableId, freeTable.IsFree, freeTable.FreeSize
                });
                // Получаем группу клиентов которые стоят в очереди
                var clientsGroups = _connection.Query<ClientsGroup>("GetClientsGroupInQueue");
                // Если есть такие, то проверям их состояние
                if (clientsGroups.Count > 0)
                {
                    ClientsStatusInTheQueue(clientsGroups);
                }
            }
        }
        
        public void ClientsStatusInTheQueue(IList<ClientsGroup> clientsGroups)
        {
            foreach (var clientsGroup in clientsGroups)
            {
                if (_random.Next(1, 11) <= 4)
                {
                    // Удаляем группу из базы данных
                    _connection.Execute("RemoveClientsGroup", clientsGroup);
                }
            }
        }

        public void OnLeave(ClientsGroup group)
        {
            // Получаем столик за которым сидит группа
            var table = _connection.Query<Table>("GetClientsGroupTable", new {group.TableId})
                .FirstOrDefault();
            if (table != null)
            {
                table.FreeSize += group.Size;
                // Удаляем группу из базы и изменяем столик
                _connection.Execute("RemoveClientsGroupAndUpdateTable", new
                {
                    group.Id, group.TableId, table.IsFree, table.FreeSize 
                });
                
                // Получаем группу клиентов которые стоят в очереди
                var clientsGroupsInTheQueue = _connection.Query<ClientsGroup>("GetClientsGroupInQueue").ToList();
                // Получаем подходящую группу по размеру на столик
                var fromQueueClient = clientsGroupsInTheQueue.FirstOrDefault(c => c.Size <= table.FreeSize);
                if (fromQueueClient != null)
                {
                    // Получаем группы стоящие перед fromQueueClient
                    List<ClientsGroup> clientsGroupAheadOfQueue = clientsGroupsInTheQueue
                        .Where(c => clientsGroupsInTheQueue.IndexOf(c) <
                                    clientsGroupsInTheQueue.IndexOf(fromQueueClient)).ToList();
                    // Изменяем размер столика 
                    table.FreeSize -= fromQueueClient.Size;
                    // Если есть кто-то стоящие перед группой, проверяем их состояние
                    if (clientsGroupAheadOfQueue.Count != 0) 
                    {
                        ClientsStatusInTheQueue(clientsGroupAheadOfQueue);
                    }
                    // Изменяем статус и TableId этой группы
                    fromQueueClient.TableId = table.Id;
                    fromQueueClient.Status = Status.OnTable;
                    // Изменяем группу и столик из базы
                    _connection.Execute("UpdateClientsGroupAndUpdateTable", new
                    {
                        fromQueueClient.Id, fromQueueClient.Status, fromQueueClient.TableId, table.IsFree, table.FreeSize
                    });
                }
            }
        }
    }
}