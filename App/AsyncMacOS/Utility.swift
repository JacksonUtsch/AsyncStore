//
//  Utility.swift
//  AsyncMacOS
//
//  Created by Jackson Utsch on 8/3/21.
//

import Foundation

func fiboncacci(nth: Int, progress: ((Int) -> Void)? = nil) async throws -> Int {
	var last = 0
	var current = 1
		
	for i in 0..<nth {
		// this is the real computation
		(current, last) = (current + last, current)
		
		// simulate compute-intensive behaviour (pause for 0.75 sec)
		await Task.sleep(75_000_000)
			
		// report progress
		progress?(i)
			
		// cooperative cancellation
		try Task.checkCancellation()
	}
		
	return last
}
