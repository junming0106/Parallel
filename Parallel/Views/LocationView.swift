//
//  LocationView.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654), // 台北101
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var sharingDuration: LocationSharingDuration = .off
    @State private var batteryLevel: Double = 0.85
    @State private var partnerLocation: CLLocationCoordinate2D?
    @State private var showingLocationPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                // 位置分享控制
                VStack(spacing: 16) {
                    HStack {
                        Text("位置分享")
                            .font(.headline)
                        Spacer()
                        Picker("分享時間", selection: $sharingDuration) {
                            Text("關閉").tag(LocationSharingDuration.off)
                            Text("1小時").tag(LocationSharingDuration.oneHour)
                            Text("24小時").tag(LocationSharingDuration.twentyFourHours)
                            Text("永久").tag(LocationSharingDuration.permanent)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    if sharingDuration != .off {
                        HStack {
                            Image(systemName: "battery.75")
                                .foregroundColor(.green)
                            Text("電量: \(Int(batteryLevel * 100))%")
                                .font(.caption)
                            Spacer()
                            Text("分享中 (僅限應用內)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // 地圖視圖
                Map(coordinateRegion: $region, annotationItems: annotations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: location.isPartner ? "heart.fill" : "person.fill")
                                .font(.title2)
                                .foregroundColor(location.isPartner ? .pink : .blue)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(location.isPartner ? Color.pink : Color.blue, lineWidth: 2)
                                        .frame(width: 30, height: 30)
                                )
                            
                            Text(location.isPartner ? "TA" : "我")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(location.isPartner ? .pink : .blue)
                        }
                    }
                }
                .frame(height: 300)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 距離和到達時間信息
                if let partnerLocation = partnerLocation {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("距離")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("1.2 公里")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("預計到達")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("15 分鐘")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        
                        // 快速操作按鈕
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "location.north.fill")
                                    Text("導航")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue)
                                )
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                    Text("通話")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green)
                                )
                            }
                            
                            Button(action: { showingLocationPicker = true }) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("設定目的地")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 常用地點
                VStack(alignment: .leading, spacing: 12) {
                    Text("常用地點")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        LocationQuickButton(
                            title: "家",
                            icon: "house.fill",
                            color: .blue,
                            action: {}
                        )
                        
                        LocationQuickButton(
                            title: "公司",
                            icon: "building.2.fill",
                            color: .gray,
                            action: {}
                        )
                        
                        LocationQuickButton(
                            title: "餐廳",
                            icon: "fork.knife",
                            color: .orange,
                            action: {}
                        )
                        
                        LocationQuickButton(
                            title: "添加",
                            icon: "plus",
                            color: .green,
                            action: {}
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("位置")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView()
        }
        .onAppear {
            // 模擬對方位置
            partnerLocation = CLLocationCoordinate2D(
                latitude: region.center.latitude + 0.005,
                longitude: region.center.longitude + 0.005
            )
        }
    }
    
    private var annotations: [LocationAnnotation] {
        var items: [LocationAnnotation] = [
            LocationAnnotation(
                coordinate: region.center,
                isPartner: false
            )
        ]
        
        if let partnerLocation = partnerLocation {
            items.append(
                LocationAnnotation(
                    coordinate: partnerLocation,
                    isPartner: true
                )
            )
        }
        
        return items
    }
}

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let isPartner: Bool
}

struct LocationQuickButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
            )
        }
    }
}

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("選擇目的地")
                    .font(.title)
                    .padding()
                
                // 這裡應該實現地圖選擇器
                Text("地圖選擇器將在此處實現")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("完成") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("設定目的地")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LocationView()
}