//
//  InfluencerMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Domain

enum InfluencerMapper {
    static func toInfluencerEntity(_ response: InfluencerResponse) -> Influencer {
        return Influencer(
            id: response.id,
            username: response.username,
            fullName: response.fullName,
            profilePicUrl: response.profilePicUrl,
            externalUrl: response.externalUrl
        )
    }
}
