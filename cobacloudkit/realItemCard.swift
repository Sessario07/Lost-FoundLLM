import SwiftUI

struct realItemCard: View {
    let item: Item
    let showClaimedDate: Bool

    var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: loadImage(named: item.imageName ?? "") ?? UIImage(systemName: "photo")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 146, height: 102)
                            .clipped()
                        
                        if !item.isClaimed {
                            Text("Unclaimed")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.orange)
                                .cornerRadius(5)
                                .fontWeight(.bold)
                        } else if item.isClaimed {
                            Text("claimed")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.green)
                                .cornerRadius(5)
                                .fontWeight(.bold)
                        }
                    }

                    Text(item.itemName ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.top, 5)
                        .padding(.bottom, 0)
                        .padding(.leading, 10)
                    
                    Text(item.category ?? "")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.top, -6)
                        .padding(.leading, 10)
                        
                    
                        

                    if item.isClaimed {
                        Text("Claimed on: \(formattedDate(item.dateClaimed))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 10)
                    } else if !item.isClaimed {
                        Text("Found on: \(formattedDate(item.dateFound))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                    }
                }
                
            }
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }

    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M/yy"
        return formatter.string(from: date)
    }
}

// PreviewProvider for SwiftUI canvas
struct ItemCardView_Previews: PreviewProvider {
    static var previews: some View {
        realItemCard(
            item: Item.dummyData()[0], // Pick the first item from dummy data
            showClaimedDate: true
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
