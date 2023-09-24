
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI


//struct JobsPopView: View {
//    @EnvironmentObject var webSocketService: WebSocketService
//    @EnvironmentObject var commonContext: ContextViewModel
//    @EnvironmentObject var slateManager: SlateManagerViewModel
//
//    var body: some View {
//        VStack {
//
//        }
//        .onReceive(webSocketService.messagePublisher) { message in
//            print(message)
//            if message.respType == "task-progress", let mindResponse = message.mindResponse["progress"] as? String {
////                do something with message.slateUUID and mindResponse you will get progress percentage which you should use in updating progress bar regularly
//            }
//        }
//    }
//}

//struct JobsPopView: View {
//    struct Job: Identifiable {
//        let id: UUID
//        let userInput: String
//        var progress: Double
//    }
//
//    @EnvironmentObject var webSocketService: WebSocketService
//    @EnvironmentObject var contextViewModel: ContextViewModel  // Access the context view model
//
//    var body: some View {
//        ScrollView {
//            LazyVStack {
//                ForEach(contextViewModel.jobs) { job in  // Use the jobs from the contextViewModel
//                    VStack(alignment: .leading) {
//                        Text(job.userInput)
//                            .font(.body)
//                            .foregroundColor(.black.opacity(0.75))
//                        ProgressView(value: job.progress/100)
//                        Button("Cancel", action: {
//                            // Implement cancellation action here.
//                        })
//                    }
//                    .padding()
//                    .background(Color.white.opacity(0.9))
//                    .cornerRadius(10)
//                }
//            }
//            .padding()
//        }
//        .background(
//            VisualBlurEffect(material: .fullScreenUI) // Change the material here
//                .overlay(
//                    Rectangle()
//                        .fill(Color(red: 241/255, green: 241/255, blue: 241/255).opacity(0.05))
//                )
//        )
//        .cornerRadius(10)
//        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
//    }
//}

//struct JobsPopView: View {
//    struct Job: Identifiable {
//        let id: UUID
//        let userInput: String
//        var progress: Double
//    }

struct JobsPopView: View {
    @EnvironmentObject var webSocketService: WebSocketService
    @EnvironmentObject var commonContext: ContextViewModel

    var body: some View {
        ScrollView {
            LazyVStack {
                // Ongoing jobs
                if commonContext.jobs.contains(where: { !$0.isCompleted }) {
                    Text("Ongoing Jobs")
                        .font(.headline)
                    ForEach(commonContext.jobs.filter({ !$0.isCompleted })) { job in
                        JobView(job: job, removeJob: {
                            commonContext.removeJob(slateUUID: job.slateUUID)
                        })
                    }
                }

                // Completed jobs
                if commonContext.jobs.contains(where: { $0.isCompleted }) {
                    HStack {
                        Text("Completed Jobs")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            commonContext.removeAllCompletedJobs()
                        }) {
                            Text("Remove All")
                                .foregroundColor(.black)
                        }
                    }
                    ForEach(commonContext.jobs.filter({ $0.isCompleted })) { job in
                        JobView(job: job, removeJob: {
                            commonContext.removeJob(slateUUID: job.slateUUID)
                        })
                    }
                }
            }
            .padding()
        }
        .background(
            VisualBlurEffect(material: .fullScreenUI)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 241/255, green: 241/255, blue: 241/255).opacity(0.05))
                )
        )
        .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
    }
}

struct JobView: View {
    @ObservedObject var job: Job
    @EnvironmentObject var slateManager: SlateManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel
    
    let removeJob: () -> Void

    var body: some View {
        HStack {
            Text(job.userInput)
                .font(.body)
                .foregroundColor(.black.opacity(0.75))
            Spacer()
            if !job.isCompleted {
                ProgressView(value: job.progress / 100)
                Button(action: {
                    // Implement stop action here
                }) {
                    Text("Stop")
                        .foregroundColor(.red)
                }
            } else {
                Button(action: {
                    removeJob()
                }) {
                    Text("Remove")
                        .foregroundColor(.blue)
                }
                Button(action: {
                    slateManager.jumpToSlate(with: job.slateUUID)
                    commonContext.isPopVisible.toggle()
                    commonContext.isJobsPopActive.toggle()
                }) {
                    Text("View Result")
                        .foregroundColor(.green)
                }

            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
    }
}

