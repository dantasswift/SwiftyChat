//
//  AvatarModifier.swift
//
//
//  Created by Enes Karaosman on 30.07.2020.
//

import SwiftUI
import Kingfisher

struct AvatarModifier<Message: ChatMessage>: ViewModifier {

    let message: Message
    let showAvatarForMessage: Bool

    @EnvironmentObject var style: ChatMessageCellStyle

    private var isSender: Bool { message.isSender }

    private var user: Message.User { message.user }

    private var incomingAvatarStyle: AvatarStyle { style.incomingAvatarStyle }

    private var outgoingAvatarStyle: AvatarStyle { style.outgoingAvatarStyle }

    private var incomingAvatarPosition: AvatarPosition { incomingAvatarStyle.avatarPosition }

    private var outgoingAvatarPosition: AvatarPosition { outgoingAvatarStyle.avatarPosition }

    /// Current avatar style
    private var currentStyle: AvatarStyle { isSender ? outgoingAvatarStyle : incomingAvatarStyle }

    /// Current avatar position
    private var currentAvatarPosition: AvatarPosition { isSender ? outgoingAvatarPosition : incomingAvatarPosition }

    private var alignToMessageBottom: some View {
        VStack {
            Spacer()
            avatar
        }
    }

    private var alignToMessageTop: some View {
        VStack {
            avatar
            Spacer()
        }
    }

    private var alignToMessageCenter: some View {
        VStack {
            Spacer()
            avatar
            Spacer()
        }
    }

    private var avatar: some View {
        let imageStyle = currentStyle.imageStyle

        return avatarImage
            .frame(
                width: imageStyle.imageSize.width,
                height: imageStyle.imageSize.height
            )
            .scaledToFit()
            .cornerRadius(imageStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: imageStyle.cornerRadius)
                    .stroke(
                        showAvatarForMessage ? imageStyle.borderColor: Color.clear,
                        lineWidth: imageStyle.borderWidth
                    )
                    .shadow(
                        color: showAvatarForMessage ? imageStyle.shadowColor: Color.clear,
                        radius: imageStyle.shadowRadius
                    )
            )
    }

    private var blankAvatar: some View {
        EmptyView()
    }

    @ViewBuilder
    private var avatarImage: some View {
        if !showAvatarForMessage {
            blankAvatar
        } else if let imageURL = user.avatarURL, currentStyle.imageStyle.imageSize.width > 0 {
            KFImage(imageURL).resizable()
        } else if let avatar = user.avatar, currentStyle.imageStyle.imageSize.width > 0 {
            Image(image: avatar).resizable()
        }
    }

    @ViewBuilder
    private var positionedAvatar: some View {
        switch currentAvatarPosition {
        case .alignToMessageTop: alignToMessageTop
        case .alignToMessageCenter: alignToMessageCenter
        case .alignToMessageBottom: alignToMessageBottom
        }
    }

    private var avatarSpacing: CGFloat {
        return switch currentAvatarPosition {
        case .alignToMessageTop(let spacing): spacing
        case .alignToMessageCenter(let spacing): spacing
        case .alignToMessageBottom(let spacing): spacing
        }
    }

    func body(content: Content) -> some View {
        HStack(spacing: avatarSpacing) {
            if !isSender { positionedAvatar.zIndex(2) }
            content
            if isSender { positionedAvatar.zIndex(2) }
        }
    }
}
