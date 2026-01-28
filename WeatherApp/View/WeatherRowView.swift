//
//  WeatherRowView.swift
//  WeatherApp
//
//  Created by  Bharath Kumar Kapu on 1/28/26.
//

import SwiftUI

struct WeatherRowView: View {

    let model: WeatherDisplayModel

    var body: some View {
        HStack(spacing: 16) {

            AsyncImage(url: model.iconURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                Text(model.city)
                    .font(.headline)

                Text(model.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(model.temperature)
                .font(.title3)
        }
        .padding(.vertical, 8)
    }
}
