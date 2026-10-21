// resources/js/Components/Pagination.jsx

import React from 'react';

export default function Pagination({ links }) {
    return (
        <div className="flex justify-center mt-4 space-x-1">
            {links.map((link, index) => (
                <a
                    key={index}
                    href={link.url || '#'}
                    dangerouslySetInnerHTML={{ __html: link.label }}
                    className={`px-3 py-1 text-sm border rounded ${
                        link.active
                            ? 'bg-blue-600 text-white'
                            : 'bg-white text-gray-700 hover:bg-gray-100'
                    } ${!link.url ? 'cursor-not-allowed opacity-50' : ''}`}
                    style={{ pointerEvents: link.url ? 'auto' : 'none' }}
                />
            ))}
        </div>
    );
}