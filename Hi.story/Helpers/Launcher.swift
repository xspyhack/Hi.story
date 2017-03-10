//
//  Launcher.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 24/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Hikit
import RealmSwift

struct Launcher {
    
    static func hi() {
        guard let realm = try? Realm() else { return }
        
        bornAuthor(withRealm: realm)
        bornHiTeam(withRealm: realm)
    }
    
    static func defaultStorybook(of userID: String) -> Storybook? {
        guard let realm = try? Realm() else { return nil }
        let predicate = NSPredicate(format: "name = %@ AND creator.id = %@", Defaults.storybookName, userID)
        return realm.objects(Storybook.self).filter(predicate).first
    }
    
    private static func bornHiTeam(withRealm realm: Realm) {
        
        let team = User()
        team.id = UUID.uuid
        team.username = "hi"
        team.nickname = "Hi Team"
        team.bio = "We craft *cool* things"
        if let image = UIImage.hi.hiTeamAvatar {
            let key = URL.hi.imageURL(withPath: "hiteam").absoluteString
            CacheService.shared.store(image, forKey: key)
            team.avatarURLString = key
        }
        team.createdAt = Date.hi.date(with: "2015-08-20", format: "yyyy-MM-dd")!.timeIntervalSince1970
        
        func teamMatter(title: String, happenedAt: String, body: String, tag: Tag) -> Matter {
            
            let matter = Matter()
            matter.title = title
            matter.happenedAt = Date.hi.date(with: happenedAt, format: "yyyy-MM-dd")!.timeIntervalSince1970
            matter.creator = team
            matter.kind = MatterKind.past.rawValue
            matter.tag = tag.rawValue
            matter.location = princePlanet()
            matter.body = body
            
            return matter
        }
        
        // Mind
        let mind = teamMatter(title: "Mind", happenedAt: "2015-08-08", body: "In my mind", tag: Tag.random())
        
        // plan
        let plan = teamMatter(title: "Plan", happenedAt: "2015-08-20", body: "Plan to do something", tag: Tag.random())
        
        // project
        let project = teamMatter(title: "Project", happenedAt: "2015-09-20", body: "Start code", tag: Tag.random())
        
        // release
        let release = teamMatter(title: "Release", happenedAt: "2016-02-01", body: "Congratulations", tag: Tag.random())
        
        // Feed
        let story = Story()
        story.title = "Welcome to Hi.story"
        story.body = "Hi.story is a simple, flexible recording app for life and time. It's easy to get started and master Hi.story, so let's show you around."
        
        story.location = princePlanet()
        story.isPublished = true
       
        // default storybook
        let book = Storybook()
        book.name = "Hi.story"
        book.creator = team
        
        story.withStorybook = book
        
        let feed = Feed()
        feed.story = story
        feed.creator = team
        
        realm.beginWrite()
        
        realm.add(team, update: true)
        realm.add(mind)
        realm.add(plan)
        realm.add(project)
        realm.add(release)
        realm.add(feed)
        
        try? realm.commitWrite()
    }
    
    private static func bornAuthor(withRealm realm: Realm) {
        let author = User()
        author.id = UUID.uuid
        author.nickname = "Blessing Software"
        author.username = "blessingsoft"
        author.bio = "Megumi soft"
        if let image = UIImage.hi.authorAvatar {
            let key = URL.hi.imageURL(withPath: "author").absoluteString
            CacheService.shared.store(image, forKey: key)
            author.avatarURLString = key
        }
        author.createdAt = Date.hi.date(with: "2333-3-13", format: "yyyy-MM-dd")!.timeIntervalSince1970
        
        let founded = Matter()
        founded.title = "Founded"
        founded.happenedAt = Date.hi.date(with: "2333-3-13", format: "yyyy-MM-dd")!.timeIntervalSince1970
        founded.location = princePlanet()
        founded.kind = MatterKind.coming.rawValue
        founded.creator = author
        founded.tag = Tag.hi.rawValue
        founded.body = "Founder: alex@blessingsoft.com"
        
        try? realm.write {
            realm.add(author, update: true)
            realm.add(founded)
        }
    }
    
    private static func princePlanet() -> Location {
        
        let location = Location()
        location.name = "b233 prince planet"
        let coordinate = Coordinate()
        coordinate.latitude = 0.0
        coordinate.longitude = 0.0
        location.coordinate = coordinate
        
        return location
    }
}
