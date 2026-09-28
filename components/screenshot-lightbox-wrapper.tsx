"use client"

import { Suspense } from "react"
import dynamic from "next/dynamic"

const ScreenshotLightbox = dynamic(
  () => import("@/components/screenshot-lightbox").then((mod) => mod.ScreenshotLightbox),
  { ssr: false }
)

interface ScreenshotLightboxWrapperProps {
  screenshots: string[]
  name: string
}

export function ScreenshotLightboxWrapper({
  screenshots,
  name,
}: ScreenshotLightboxWrapperProps) {
  return (
    <Suspense fallback={<div className="h-64" />}>
      <ScreenshotLightbox screenshots={screenshots} name={name} />
    </Suspense>
  )
}
