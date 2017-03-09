//
//  TaskViewController.swift
//  TodoList
//
//  Created by Vlad-Constanti Buhaescu on 07/03/2017.
//
//

import Vapor
import VaporSQLite
import Foundation
import HTTP

class Task : NodeRepresentable {
    var taskId :Int!
    var title :String!
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node :["taskId":self.taskId, "title":self.title])
    }
    
}

extension Task {
    convenience init?(node: Node) {
        self.init()
        guard let taskId = node["taskId"]?.int,
              let title = node["title"]?.string
            else {
                return nil
        }
        
        self.taskId = taskId
        self.title = title
    }
}

final class TaskViewController {
    
    func addRoutes(drop: Droplet) {
        drop.get("tasks","all",handler :getAll)
        drop.post("tasks","create",handler :create)
        drop.post("tasks","delete",handler :delete)
    }
    
    func delete(_ req: Request) throws -> ResponseRepresentable {
        
        guard let taskId = req.data["taskId"]?.int else {
                throw Abort.badRequest
        }

        try drop.database?.driver.raw("DELETE FROM Tasks WHERE taskId = ?",[taskId])
        
        return try JSON(node: ["succes":true])
    }
    
    func create(_ req: Request) throws -> ResponseRepresentable {
        
        guard let title = req.data["title"]?.string,
            let taskId = req.data["taskId"]?.int else {
            throw Abort.badRequest
        }
        
        try drop.database?.driver.raw("INSERT INTO Tasks(title,taskId) VALUES(?,?)",[title,taskId])
        
        return try JSON(node :["succes":true])
        
    }
    
    
    
    
    func getAll(_ req: Request) throws -> ResponseRepresentable {
        let result = try drop.database?.driver.raw("SELECT taskId, title from Tasks;")
        
        guard let nodes = result?.nodeArray else {
            
            return try JSON(node :[])
            
        }
        
        let tasks = nodes.flatMap(Task.init)
        
        return try JSON(node :tasks)
    }
}
