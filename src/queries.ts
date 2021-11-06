import { gql } from "apollo-boost"

export const CREATE_SELLER = gql`
  mutation Mutation($userId: ID!, $email: String!) {
    createSeller(id: $userId, email: $email) {
      code
      success
      message
      seller {
        id
        email
      }
    }
  }
`

export const CREATE_VA = gql`
  mutation Mutation($userId: ID!, $email: String!) {
    createVirtualAssistant(id: $userId, email: $email) {
      code
      success
      message
      virtualAssistant {
        id
        email
      }
    }
  }
`

export const CREATE_TEAM = gql`
  mutation Mutation($userId: ID!, $email: String!) {
    createVirtualAssistant(id: $userId, email: $email) {
      code
      success
      message
      virtualAssistant {
        id
        email
      }
    }
  }
`
