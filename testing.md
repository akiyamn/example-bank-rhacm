# How to test this application

**Note** The user database in RHSSO and in the application (stored in CockroachDB) are separate. It is possible to have a user created in one and not the other when the app is not fully functional. When the app is fully functional, these two sources are more or less syncronised.

## RHSSO realm creation
1. Run the rhsso-integration-bank-app Job on the hub cluster (or just enable in in ArgoCD).
2. Go to the RHSSO admin portal and login as an admin.
3. Click on the created realm called `banksso`.
4. Click on "Clients" and you should see a client named `nodeclient`.
5. Click on "Users", then "Show all users". You should see a user called `knative`.

## Front end visible
1. Enable the `mobile-simulator` application in the 3-apps `kustomization.yaml`.
2. Go to a managed cluster that is part of the `multicloud-cluster-set` cluster set.
3. Go to the created `bank-infra` namespace.
4. There should be a deployment called `mobile-simulator` running.
5. Click on the exposed route and you should see the front end working.

## Front end URL consistent across clusters
1. Enable the `mobile-simulator` application in the 3-apps `kustomization.yaml`.
2. Go to two different managed clusters that are part of the `multicloud-cluster-set` cluster set.
3. On each cluster, do the following:
   1. Go to the created `bank-infra` namespace.
   2. There should be a deployment called `mobile-simulator` running.
   3. Click on the exposed route and you should see the front end working.
4. The URLs on both clusters should both be the same

## Front end still visible when clusters go down
1. Enable the `mobile-simulator` application in the 3-apps `kustomization.yaml`.
2. As it's hard to predict the cluster you are going to be routed to, if you have many clusters in `multicloud-cluster-set`, spin down the `mobile-simulator` (in the `bank-infra` namespace) to zero pods in all but 2 to 4 clusters. This is to make it easier to test.
3. Open the log files of each of the `mobile-simulator` pods that remain.
4. Open the bank front-end on one of the clusters. If it has been load balanced, the URL should be the same on all clusters.
5. On the bank app, click the "Login" button (without actually logging in), then immediately go back to the home screen.
6. There should be new output in one of the logs you have open. This is the pod (and thus the cluster) that you have been routed to.
7. Scale the deployment on that cluster to zero. This will kill the pod that you were accessing to.
8. Refresh the bank app page. It should fail while the load balancer finds a new cluster to route you to.
9. After about 10 seconds, refresh you should be routed to a new cluster.
10. On the bank app, click the "Login" button (without actually logging in), then immediately go back to the home screen.
11. There should be  new output on one of the other clusters. This shows that you were indeed routed to a new cluster.
## App creates a new user in RHSSO
1. Follow [Front end visible](#front-end-visible).
2. In the bank app, go to "Login" then "Create account".
3. Take note of the user name that was automatically generated and click "Create".
  
Note: If you don't have a database set up, you might be stuck on "Creating user profile..." or see "User marked for deletion...". Ignore these messages.

4. Go to the RHSSO admin portal and login as an admin.
5. Click on the created realm called `banksso`.
6. Click on "Users", then "Show all users".
7. You should see a user with the same user name that you took note of in step 3.
## Front end recognises user in RHSSO
1. Follow [App creates a new user in RHSSO](#app-creates-a-new-user-in-rhsso).
2. Go back to the login screen on the bank app.
3. Login using the generated user name you just created. Put the user name in both the user name and password boxes. **This is case sensitive and does not automatically trim whitespace. Make sure there is no space at the start.**
4. If you *don't* have the `user-service`, `transaction-service` and database working, you will see the text "User marked for deletion" appear. This indicates that you did login but could not access the database. This is a success.
5. If you *do* have the `user-service`, `transaction-service` and database setup and working, you should see an empty list of transactions.
   - Click on the person icon on the bottom right of the screen. You should see the user's full name provided. Ignore the year.
## Create a new user in the app
1. Follow [Front end visible](#front-end-visible).
2. In the bank app, go to "Login" then "Create account".
3. Take note of the user name that was automatically generated and click "Create".
4. You should see an empty list of transactions.
5. Click on the gear icon on the bottom right of the screen. You should see the user's full name provided. Ignore the year.

Note: If you don't have a database set up, you might be stuck on "Creating user profile..." or see "User marked for deletion...".

## Login as user in the app
1. Follow [Front end visible](#front-end-visible).
2. In the bank app, go to "Login" then "Create account".
3. Copy the user name that was automatically generated and click "Create".
4. You should see an empty list of transactions.

Note: If you don't have a database set up, you might be stuck on "Creating user profile..." or see "User marked for deletion...".

5. Click on the gear icon on the bottom right of the screen. You should see the user's full name provided. Ignore the year.
6.  Click the button labelled "Log Out". You will be taken to the login screen.
7.  Login using the generated user name you just created. Paste the user name in both the user name and password boxes. **This is case sensitive and does not automatically trim whitespace. Make sure there is no space at the start.**
8.  You should be directed to the same transaction page as before.
## Login as user in the app and make transactions
1. Follow [Front end visible](#front-end-visible).
2. In the bank app, go to "Login" then "Create account".
3. Copy the user name that was automatically generated and click "Create".
4. You should see an empty list of transactions.

Note: If you don't have a database set up, you might be stuck on "Creating user profile..." or see "User marked for deletion...".

5. Click on the gear icon on the bottom right of the screen. You should see the user's full name provided. Ignore the year.
6. Press the back button on the fake phone.
7. Make some purchases by clicking on the various buttons.
8. Go back to the transaction screen by clicking on the bank icon. You should see the transactions you just made.
9. Click on the gear icon on the bottom right of the screen.
10. Click the button labelled "Log Out". You will be taken to the login screen.
11. Login using the generated user name you just created. Paste the user name in both the user name and password boxes. **This is case sensitive and does not automatically trim whitespace. Make sure there is no space at the start.**
12. You should be directed to the same transaction page as before, with all of your transactions in tact.
## Can see and accumulate reward points
1. Follow [Front end visible](#front-end-visible).
2. In the bank app, go to "Login" then "Create account".
3. Copy the user name that was automatically generated and click "Create".
4. You should see an empty list of transactions.

Note: If you don't have a database set up, you might be stuck on "Creating user profile..." or see "User marked for deletion...".
6. Press the back button on the fake phone.
7. Make some purchases by clicking on the various buttons.
8. Go back to the transaction screen by clicking on the bank icon. You should see the transactions you just made.
9. The number below the "Points" label should no longer be zero and you should have a number next to each transaction as opposed to just a dash.
## Transactions consistent across clusters
1. Follow [Front end URL consistent across clusters](#front-end-url-consistent-across-clusters).
Perform the following on one cluster:
2. In the bank app, go to "Login" then "Create account".
3. Copy the user name that was automatically generated and click "Create".
4. You should see an empty list of transactions.
5. Press the back button on the fake phone.
6. Make some purchases by clicking on the various buttons.
7. Go back to the transaction screen by clicking on the bank icon. You should see the transactions you just made.
8. Leave the tab or window open
Perform the following on any number of other managed clusters:
9.  Login using the generated user name you just created. Paste the user name in both the user name and password boxes. **This is case sensitive and does not automatically trim whitespace. Make sure there is no space at the start.**
10.  You should be directed to the same transaction page as before.
11.  Compare the transactions on this screen with the other cluster(s). They should be the same.
12.  *If you have the Knative service set up* compare the point values on each cluster. They should also be the same.