# Description:
#   Creating backlogs and tasks on JIRA
#
# Commands:
#   hubot create <JIRA_PROJECT> backlog <BACKLOG>,<TASK>,... - Create a backlog and each sub-tasks on JIRA
#   hubot create <JIRA_PROJECT> backlog <BACKLOG>, - Create a backlog on JIRA
 
Request = require 'request-promise'
Promise = require 'bluebird'
 
# [B](f: (A) ⇒ [B]): [B]
Array.prototype.flatMap = (lambda) ->
  Array.prototype.concat.apply([], this.map(lambda))
 
class Jira
  constructor: (project, component) ->
    @_project = project
    @_component = component
 
  _get: (path) ->
    if process.env.JIRA_URL
      options =
        url: "#{process.env.JIRA_URL}#{path}"
        json: true
        auth:
          user: process.env.JIRA_USER
          pass: process.env.JIRA_PASSWORD
      Request(options).then (body) ->
        if body.errors?.length > 0 or body.errorMessages
          throw new Error(JSON.stringify body)
        else
          body
    else
      new Promise (resolve) -> setTimeout (-> resolve issues: []), 500
 
  _post: (path, data) ->
    if process.env.JIRA_URL
      options =
        url: "#{process.env.JIRA_URL}#{path}"
        method: 'POST'
        body: data
        json: true
        auth:
          user: process.env.JIRA_USER
          pass: process.env.JIRA_PASSWORD
      console.log "Sending HTTP POST #{path} #{JSON.stringify data}"
      Request(options).then (body) ->
        if body.errors?.length > 0 or body.errorMessages
          throw new Error(JSON.stringify body)
        else
          body
    else
      console.log "Dry-run HTTP POST #{path} #{JSON.stringify data}"
      new Promise (resolve) -> setTimeout (-> resolve issues: [key: 'XXX']), 500
 
  createBacklogs: (backlogs) ->
    if backlogs?.length > 0
      @_post '/rest/api/2/issue/bulk',
        issueUpdates: backlogs.map (backlog) =>
          fields:
            project:
              key: @_project
            components: [name: @_component]
            summary: backlog.name
            issuetype:
              id: process.env.JIRA_BACKLOG_ID
 
  createTasks: (tasks) ->
    if tasks?.length > 0
      @_post '/rest/api/2/issue/bulk',
        issueUpdates: tasks.map (task) =>
          fields:
            project:
              key: @_project
            components: [name: @_component]
            summary: task.name
            timetracking:
              originalEstimate: task.hours
            parent:
              key: task.parentKey
            issuetype:
              id: process.env.JIRA_SUBTASK_ID
 
 
findBacklogNotation = (lines) ->
  lines.split(/\n/).map (line) ->
    if m = line.match /backlog (.+?),(.*)$/
      name: m[1]
      tasks: m[2].split(/,/)
        .map (token) ->
          if m = token.match /^(.+?)([\d\.]*)$/
            name: m[1]
            hours: m[2]
        .filter (task) -> task?.name
  .filter (backlog) ->
    backlog?.name
 
 
module.exports = (robot) ->
 
  robot.respond /create (.+?) backlog/m, (res) ->
    jiraProjectKey = res.match[1]
    jiraComponent = undefined
    jira = new Jira(jiraProjectKey, jiraComponent)
 
    backlogs = findBacklogNotation(res.message.text)
 
    res.reply "Creating #{backlogs.length} backlog(s)"
    jira.createBacklogs(backlogs)
      .tap (created) ->
        if created
          res.reply "Created #{created.issues.length} backlog(s)"
      .then (created) ->
        backlogs.forEach (backlog, backlogIndex) ->
          backlogKey = created.issues[backlogIndex].key
          backlog.tasks.forEach (task) -> task.parentKey = backlogKey
        backlogs.flatMap (backlog, backlogIndex) ->
          backlog.tasks
      .then (tasks) ->
        res.reply "Creating #{tasks.length} task(s)"
        jira.createTasks(tasks)
      .tap (created) ->
        if created
          res.reply "Created #{created.issues.length} task(s)"
      .catch (e) ->
        res.reply "Failed: #{e}"
 
