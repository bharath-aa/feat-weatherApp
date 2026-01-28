//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//

import SwiftUI

struct WeatherView: View {
    
    private enum Constants {
        static let navigationTitle = "Weather".localizedCapitalized
        static let searchPlaceholder = "Enter city".localizedCapitalized
    }

    @StateObject private var viewModel: WeatherViewModel

    init(viewModel: WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: .zero) {
            content
        }
        .navigationTitle(Constants.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.cityInput, prompt: Constants.searchPlaceholder)
        .onSubmit(of: .search) {
            if viewModel.cityInput.isEmpty == false {
                viewModel.searchTapped()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.screenState {
        case .initial:
            ProgressView()
                .padding()
        case .error(let message):
            List {
                Section("Status") {
                    HStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading) {
                            Text("Error")
                                .font(.headline)

                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button("Go to Home") {
                            viewModel.onAppear()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                }
            }
        case .content:
            List {
                if let current = viewModel.currentLocationModel {
                    Section("Current Location") {
                        WeatherRowView(model: current)
                    }
                }

                if viewModel.recentResults.isEmpty == false {
                    Section("Recent Searches") {
                        ForEach(viewModel.recentResults) { model in
                            WeatherRowView(model: model)
                        }
                    }
                }
            }
            .refreshable {
                viewModel.onAppear()
            }
        }
    }
}

