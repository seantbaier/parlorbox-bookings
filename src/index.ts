import aws from "aws-sdk"
import ApolloClient, { gql } from "apollo-boost"
import "cross-fetch/polyfill"
import { CREATE_SELLER, CREATE_VA } from "./queries"

const cognitoidentityserviceprovider = new aws.CognitoIdentityServiceProvider({
  apiVersion: "2016-04-18",
})

async function addUserToGroup(groupName: string, userPoolId: string, username: string) {
  const addUserParams = {
    GroupName: groupName,
    UserPoolId: userPoolId,
    Username: username,
  }

  try {
    console.log(`Attempting to add UserName=${username} to UserGroup=${groupName}`)
    await cognitoidentityserviceprovider.adminAddUserToGroup(addUserParams).promise()
    console.log(`Successfully added ${username} to UserGroup=${groupName}`)
  } catch (err) {
    console.log(`ERROR:::Failed to add ${username} to UserGroup=${groupName}`)
    console.error(err)
  }
}

async function createNewUserItem(username: string, email: string, userType: string) {
  const client = new ApolloClient({
    uri: process.env.HTTP_GRAPHQL_ENDPOINT,
  })

  const mutation = userType === "seller" ? CREATE_SELLER : CREATE_VA
  const response = await client.mutate({
    mutation,
    variables: {
      userId: username,
      email: email,
    },
  })
  console.log(`Successfully created ${userType} ${JSON.stringify(response, null, 2)}`)
}

async function createNewTeamItem(username: string, email: string, userType: string) {
  const client = new ApolloClient({
    uri: process.env.HTTP_GRAPHQL_ENDPOINT,
  })

  const mutation = userType === "seller" ? CREATE_SELLER : CREATE_VA
  const response = await client.mutate({
    mutation,
    variables: {
      userId: username,
      email: email,
    },
  })
  console.log(`Successfully created ${userType} ${JSON.stringify(response, null, 2)}`)
}

export const handler = async (event: any, context: any) => {
  const { userName, userPoolId, request } = event

  const userAttributes = request?.userAttributes
  const userType = userAttributes?.["custom:userGroup"]
  const email = userAttributes?.email

  await addUserToGroup(userType, userPoolId, userName)
  await createNewUserItem(userName, email, userType)

  return event
}
