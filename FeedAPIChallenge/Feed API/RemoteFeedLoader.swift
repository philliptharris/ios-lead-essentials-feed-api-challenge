//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success((let data, let httpResponse)):
				guard httpResponse.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}
				do {
					_ = try JSONDecoder().decode([RemoteImage].self, from: data)
				} catch {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}

	private struct RemoteImage: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
	}
}
