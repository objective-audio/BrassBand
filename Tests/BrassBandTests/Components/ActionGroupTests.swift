import Testing

@testable import BrassBand

struct ActionGroupTests {
    @Test func equals() async throws {
        let group1a = ActionGroup()
        let group1b = group1a
        let group2 = ActionGroup()

        #expect(group1a == group1a)
        #expect(group1a == group1b)
        #expect(group1a != group2)
    }
}
