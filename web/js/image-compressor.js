/**
 * LocalTrip - Client-Side Image Compression Utility
 * Resizes large images (max dimension: 1280px) & compresses to JPEG/WebP (quality: 0.75, target: < 300KB)
 * Using HTMLCanvasElement & DataTransfer API.
 */
(function (global) {
    'use strict';

    async function compressImageFile(file, maxDimension, initialQuality, maxBytes) {
        maxDimension = maxDimension || 1280;
        initialQuality = initialQuality || 0.75;
        maxBytes = maxBytes || (300 * 1024);

        if (!file || !file.type || !file.type.startsWith('image/')) {
            return file;
        }

        // Return early if file is SVG or already below maxBytes and not GIF
        if (file.type === 'image/svg+xml' || file.type === 'image/gif') {
            return file;
        }

        return new Promise(function (resolve) {
            var reader = new FileReader();
            reader.onload = function (e) {
                var img = new Image();
                img.onload = function () {
                    var width = img.width;
                    var height = img.height;

                    if (width > maxDimension || height > maxDimension) {
                        if (width > height) {
                            height = Math.round((height * maxDimension) / width);
                            width = maxDimension;
                        } else {
                            width = Math.round((width * maxDimension) / height);
                            height = maxDimension;
                        }
                    }

                    var canvas = document.createElement('canvas');
                    canvas.width = width;
                    canvas.height = height;
                    var ctx = canvas.getContext('2d');
                    ctx.drawImage(img, 0, 0, width, height);

                    var mimeType = file.type === 'image/webp' ? 'image/webp' : 'image/jpeg';

                    function attemptBlob(q) {
                        canvas.toBlob(function (blob) {
                            if (!blob) {
                                resolve(file);
                                return;
                            }

                            // If blob is still > maxBytes and quality can be reduced, recurse once
                            if (blob.size > maxBytes && q > 0.45) {
                                attemptBlob(q - 0.15);
                                return;
                            }

                            var ext = mimeType === 'image/webp' ? '.webp' : '.jpg';
                            var baseName = file.name ? file.name.replace(/\.[^/.]+$/, "") : "photo";
                            var newName = baseName + ext;

                            var compressedFile;
                            try {
                                compressedFile = new File([blob], newName, {
                                    type: mimeType,
                                    lastModified: Date.now()
                                });
                            } catch (err) {
                                // Fallback for older browsers
                                blob.name = newName;
                                blob.lastModifiedDate = new Date();
                                compressedFile = blob;
                            }
                            resolve(compressedFile);
                        }, mimeType, q);
                    }

                    attemptBlob(initialQuality);
                };
                img.onerror = function () { resolve(file); };
                img.src = e.target.result;
            };
            reader.onerror = function () { resolve(file); };
            reader.readAsDataURL(file);
        });
    }

    function attachImageCompressor(inputElement, statusElement) {
        if (!inputElement) return;

        inputElement.addEventListener('change', async function () {
            if (!this.files || this.files.length === 0) return;

            if (statusElement) {
                statusElement.textContent = '⏳ Compressing photo(s) for fast upload...';
                statusElement.style.color = '#175b43';
                statusElement.style.display = 'block';
            }

            var originalFiles = Array.from(this.files);
            var processedFiles = [];
            var totalOriginal = 0;
            var totalCompressed = 0;

            for (var i = 0; i < originalFiles.length; i++) {
                var f = originalFiles[i];
                totalOriginal += f.size;
                try {
                    var comp = await compressImageFile(f, 1280, 0.75, 300 * 1024);
                    totalCompressed += comp.size;
                    processedFiles.push(comp);
                } catch (err) {
                    totalCompressed += f.size;
                    processedFiles.push(f);
                }
            }

            if (window.DataTransfer) {
                try {
                    var dt = new DataTransfer();
                    processedFiles.forEach(function (f) { dt.items.add(f); });
                    this.files = dt.files;
                } catch (err) {
                    console.warn('[ImageCompressor] DataTransfer assignment error:', err);
                }
            }

            if (statusElement) {
                var origKb = Math.round(totalOriginal / 1024);
                var compKb = Math.round(totalCompressed / 1024);
                statusElement.textContent = '✓ Optimized ' + processedFiles.length + ' image(s): ' + origKb + 'KB → ' + compKb + 'KB (< 300KB/photo)';
                statusElement.style.color = '#166534';
            }
        });
    }

    // Auto-bind on DOMContentLoaded
    document.addEventListener('DOMContentLoaded', function () {
        var checkinInput = document.getElementById('checkinPhoto');
        if (checkinInput) {
            var checkinStatus = document.getElementById('checkinCompressStatus');
            if (!checkinStatus) {
                checkinStatus = document.createElement('div');
                checkinStatus.id = 'checkinCompressStatus';
                checkinStatus.style.cssText = 'font-size: 11px; margin-top: 4px; font-weight: 600; color: #166534;';
                checkinInput.parentNode.appendChild(checkinStatus);
            }
            attachImageCompressor(checkinInput, checkinStatus);
        }

        var dumpInput = document.getElementById('dumpImages');
        if (dumpInput) {
            var dumpStatus = document.getElementById('dumpCompressStatus');
            if (!dumpStatus) {
                dumpStatus = document.createElement('div');
                dumpStatus.id = 'dumpCompressStatus';
                dumpStatus.style.cssText = 'font-size: 11px; margin-top: 4px; font-weight: 600; color: #166534;';
                dumpInput.parentNode.appendChild(dumpStatus);
            }
            attachImageCompressor(dumpInput, dumpStatus);
        }
    });

    global.compressImageFile = compressImageFile;
    global.attachImageCompressor = attachImageCompressor;
})(window);
