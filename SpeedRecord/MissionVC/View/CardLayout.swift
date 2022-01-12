//
//  CardLayout.swift
//  Card
//
//  Created by Alghero_Mac_02 on 2020/10/8.
//

import UIKit

class CardLayout: UICollectionViewFlowLayout {

    /// MARK: - 一些计算属性 防止编写冗余代码
    
    private var collectionViewHeight: CGFloat {
      return collectionView!.frame.height
    }
    private var collectionViewWidth: CGFloat {
      return collectionView!.frame.width
    }
    
    private var cellWidth: CGFloat {
      return collectionViewWidth*0.8
    }
    
    private var cellMargin: CGFloat {
      return (collectionViewWidth - cellWidth)/8
    }
    // 内边距
    private var margin: CGFloat {
      return (collectionViewWidth - cellWidth)/2
    }
    
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        minimumLineSpacing = cellMargin
        print("screen height = \(UIScreen.main.bounds.size.height)")
//        if(UIScreen.main.bounds.height <= 667){
//            itemSize = CGSize(width: cellWidth, height: collectionViewHeight * 0.8)
//
//        }else if(UIScreen.main.bounds.height <= 667){
//
//        }else{
//
//        }
        itemSize = CGSize(width: cellWidth, height:  127)
        print("itemSize = \(itemSize)")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView else { return nil }
        // 1
        guard let visibleAttributes = super.layoutAttributesForElements(in: rect) else { return nil }

        // 2
        let centerX = collectionView.contentOffset.x + collectionView.bounds.size.width/2
        for attribute in visibleAttributes {

          // 3
          let distance = abs(attribute.center.x - centerX)
          
          // 4
          let aprtScale = distance / collectionView.bounds.size.width

          // 5
          let scale = abs(cos(aprtScale * CGFloat(Double.pi/4)))
          attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        // 6
        return visibleAttributes
    }
    
    /// 当停止滑动，确保有一Cell是位于屏幕最中央
     override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
         // 可见范围
         let lastRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height)
         //获得collectionVIew中央的X值(即显示在屏幕中央的X)
         let centerX = proposedContentOffset.x + self.collectionView!.frame.width * 0.5;
         //这个范围内所有的属性
         let attributes : [UICollectionViewLayoutAttributes] = self.layoutAttributesForElements(in: lastRect)!;
         //需要移动的距离
         var adjustOffsetX = CGFloat(MAXFLOAT);
         var tempOffsetX : CGFloat;
         for attr in attributes {
             //计算出距离中心点 最小的那个cell 和整体中心点的偏移
             tempOffsetX = attr.center.x - centerX;
             if abs(tempOffsetX) < abs(adjustOffsetX) {
                 adjustOffsetX = tempOffsetX;
             }
         }
         //偏移坐标
         return CGPoint(x: (proposedContentOffset.x + adjustOffsetX), y: proposedContentOffset.y);
     }
    
    
    // 是否实时刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
