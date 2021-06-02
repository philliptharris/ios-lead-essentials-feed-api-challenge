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
			completion(Swift.Result { try Self.mapClientResult(result) })
		}
	}

	private static func mapClientResult(_ clientResult: HTTPClient.Result) throws -> [FeedImage] {
		switch clientResult {
		case .failure:
			throw Error.connectivity
		case .success((let data, let httpResponse)):
			guard httpResponse.statusCode == 200 else {
				throw Error.invalidData
			}
			do {
				_ = try JSONDecoder().decode([RemoteImage].self, from: data)
				return []
			} catch {
				throw Error.invalidData
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
