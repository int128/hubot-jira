/*
 * Description:
 * Receive webhook from JIRA
 */

const quote = content => content.replace(/^|\r\n|\r|\n/g, '\r\n> ');

const isChanged = (changelog, fields) =>
  changelog && changelog.items.find(item => fields.find(field => item.field === field));

const baseUrl = url => url.replace(/\/rest\/api\/.+/, '');

const renderUser = user => `@${user.name}`;

const renderAssignee = issue => issue.fields.assignee ? `(assigned to ${renderUser(issue.fields.assignee)})` : '';

const renderIssue = issue => quote(
  `**[${issue.key}](${baseUrl(issue.self)}/browse/${issue.key}) ${issue.fields.summary}** ${renderAssignee(issue)}\r\n${issue.fields.description || ''}`
);

const renderComment = (issue, comment) => quote(
  `**[${issue.key}](${baseUrl(issue.self)}/browse/${issue.key}) ${issue.fields.summary}** ${renderAssignee(issue)}\r\n${comment.body}`
);


module.exports = function (robot) {

  robot.router.post('/hubot/jira', (req, res) => {
    if (req.body) {
      const send = content => robot.send({room: process.env.BOT_CHANNEL_ID}, content);

      const { webhookEvent, user, issue, changelog, comment } = req.body;

      switch (webhookEvent) {
        case 'jira:issue_updated':
          if (isChanged(changelog, ['summary', 'description', 'assignee'])) {
            send(`${renderUser(user)} updated: ${renderIssue(issue)}`);
          }
          if (comment) {
            send(`${renderUser(user)} commented: ${renderComment(issue, comment)}`);
          }
          break;

        case 'jira:issue_created':
          send(`${renderUser(user)} created: ${renderIssue(issue)}`);
          break;

        case 'jira:issue_deleted':
          send(`${renderUser(user)} deleted: ${renderIssue(issue)}`);
          break;
      }
    }

    res.end();
  });

}
