# Active User Analysis

## Parameters

|        Name        | Type |          Description           | Is Optional |
| ------------------ | ---- | ------------------------------ | ----------- |
| daily_active_users |      | Heap daily active users table. |             |


## Output Metrics

### active_user_analysis_metrics

|             Name              | Index |                            Description                            | Source |
| ----------------------------- | ----- | ----------------------------------------------------------------- | ------ |
| WEEKLY_USAGE_BY_PLG           |       | Weekly hours used by free PLG users                               |        |
| PLG_WEEKLY_USERS_WILL_REPEAT  |       | Weekly count of new free users this week that return another week |        |
| ENT_WEEKLY_FIRST_REPEAT_USERS |       | Weekly count of first week an enterprise user repeats             |        |
| PLG_WEEKLY_FIRST_REPEAT_USERS |       | Weekly count of first week a PLG user repeats                     |        |
| ENT_WEEKLY_USERS_WILL_REPEAT  |       | Weekly count of new free users this week that return another week |        |
| WEEKLY_TOTAL_ENT_REPEAT_USERS |       | Weekly count of all enterprise repeat users                       |        |
| WEEKLY_USERS                  |       | Total number of weekly users                                      |        |
| PLG_WEEKLY_NEW_USERS          |       | New PLG users in the week                                         |        |
| WEEKLY_USER_DAYS              |       | Total number of users by day in the week                          |        |
| ENT_WEEKLY_NEW_USERS          |       | New enterprise users in the week                                  |        |
| WEEKLY_USERS_BY_ENT           |       | Total weekly enterprise users                                     |        |
| ORG_TYPE                      |       | Organization type (always enterprise)                             |        |
| WEEK                          |       | Week the data is for                                              |        |
| WEEKLY_USAGE_BY_ENT           |       | Total hours spent by enterprise users                             |        |
| WEEKLY_USERS_BY_PLG           |       | Total weekly free users                                           |        |
| WEEKLY_USAGE                  |       | Total hours used by all users                                     |        |
| WEEKLY_TOTAL_PLG_REPEAT_USERS |       | Weekly count of all PLG repeat users                              |        |


## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/accelerators/active_user_analysis.yml" %}