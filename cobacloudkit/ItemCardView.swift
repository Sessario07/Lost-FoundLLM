//
//  ItemCardView.swift
//  cobacloudkit
//
//  Created by Nicholas  on 07/04/25.
//

import SwiftUI

struct ItemCardView: View {
    let item: Item
    let showClaimedDate: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Item Image
            Image(uiImage: loadImage(named: item.imageName ?? "") ?? UIImage(systemName: "photo")!)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(Circle())


            // Main Text Stack
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 3) {
                    Text(item.itemName ?? "")
                    if  item.isClaimed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    else if item.isClaimed == false {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                    }
                }
                .font(.headline)

                
                Text(showClaimedDate && item.isClaimed
                     ? "Claimed at \(formattedDate(item.dateClaimed))"
                     : "Found at \(formattedDate(item.dateFound))")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
            }

            Spacer()

            // Top-right Category and Arrow
            VStack(alignment: .trailing, spacing: 8) {
                Text(item.category ?? "")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                    .bold(true)
                    .padding(.vertical, 2)


                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M/yy"
        return formatter.string(from: date)
    }
}
