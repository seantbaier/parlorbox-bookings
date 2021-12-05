SELLER_QUERY = """
    mutation Mutation($createSellerId: ID!, $email: String!) {
        createSeller(id: $createSellerId, email: $email) {
            code
            success
            message
        }
    }
"""
